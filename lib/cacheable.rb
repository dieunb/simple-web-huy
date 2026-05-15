# frozen_string_literal: true

require 'redis'
require 'logger'

# Cacheable — a mixin that adds Redis-backed caching to any ActiveRecord model.
#
# Usage:
#   class MyModel < ActiveRecord::Base
#     include Cacheable
#
#     CACHE_PREFIX = 'my_model'
#     CACHE_TTL    = 3600
#
#     def self.cache_includes
#       :related_model   # override to eager-load associations from JSON
#     end
#   end
#
# The including class MUST define:
#   CACHE_PREFIX  – string key namespace used in Redis (e.g. "product")
#   CACHE_TTL     – integer TTL in seconds
#
# Class methods provided (via ClassMethods):
#   redis_client                  – memoised Redis connection
#   cache_prefix                  – returns self::CACHE_PREFIX
#   cache_includes                – override to specify associations to embed (default: nil)
#   find_cached(id)               – cache-aware single-record find; hydrates associations
#   fetch_multi_cached(ids)       – batch fetch via Redis MGET; DB fallback for misses only
#
# Instance methods provided:
#   cache_self                    – serialises this record (with associations) into Redis
#   sync_cache                    – cache_self + bust collection keys (after_save)
#   invalidate_cache              – remove individual record key (after_destroy)
module Cacheable
  def self.included(base)
    base.extend(ClassMethods)
    base.after_save    :sync_cache
    base.after_destroy :invalidate_cache
  end

  # ---------------------------------------------------------------------------
  # Class-level helpers
  # ---------------------------------------------------------------------------
  module ClassMethods
    # Memoised Redis client; reads REDIS_URL from the environment.
    def redis_client
      @redis_client ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    end

    # Shared logger that writes to stdout — no Rails dependency.
    def cache_logger
      @cache_logger ||= Logger.new($stdout)
    end

    # Convenience accessor so instance methods can reach the constant without
    # hard-coding the class name.
    def cache_prefix
      self::CACHE_PREFIX
    end

    # Override in the including model to specify which associations should be
    # embedded in the JSON payload and pre-loaded when deserialising.
    # Accepts the same values as ActiveRecord's +to_json(include:)+.
    # e.g.  :category  or  [:category, :tags]
    def cache_includes
      nil
    end

    # Return a record by id, preferring the Redis cache.
    # Associations listed in +cache_includes+ are pre-loaded from the stored
    # JSON so no additional SQL is fired when the view accesses them.
    # Falls back to the database on a cache miss or a Redis error.
    def find_cached(id)
      cache_key   = "#{cache_prefix}:#{id}"
      cached_data = redis_client.get(cache_key)
      return hydrate(JSON.parse(cached_data)) if cached_data

      record = find_by(id: id)
      return nil unless record

      redis_client.setex(cache_key, self::CACHE_TTL, record.to_json(include: cache_includes))
      record
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in find_cached: #{e.message}. Falling back to DB.")
      find_by(id: id)
    end

    # Batch-fetch records by a list of ids using a single Redis MGET call.
    #
    # Strategy (Individual Records cache — pagination-friendly):
    #   1. Build one cache key per id and call MGET in a single round-trip.
    #   2. Hydrate all cache hits immediately (no SQL).
    #   3. Collect the missed ids, load them from the DB in one query,
    #      warm each individual key via cache_self, then merge with hits.
    #   4. Return records in the same order as the supplied ids array.
    #
    # Falls back to a plain DB query for all ids on any Redis error.
    #
    #   ids = Product.order(:name).limit(20).offset(page * 20).pluck(:id)
    #   products = Product.fetch_multi_cached(ids)
    #
    def fetch_multi_cached(ids)
      return [] if ids.empty?

      keys = ids.map { |id| "#{cache_prefix}:#{id}" }
      hits, missed_ids = build_hits_from_cache(ids, redis_client.mget(*keys))
      load_missed_records(hits, missed_ids)
      ids.filter_map { |id| hits[id.to_s] }
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in fetch_multi_cached: #{e.message}. Falling back to DB.")
      db_fallback_ordered(ids)
    end

    private

    # Partition MGET results into a hits hash and a list of missed ids.
    def build_hits_from_cache(ids, raw_values)
      hits = {}
      missed_ids = []
      ids.zip(raw_values).each do |id, raw|
        raw ? hits[id.to_s] = hydrate(JSON.parse(raw)) : missed_ids << id
      end
      [hits, missed_ids]
    end

    # DB fallback that preserves the caller-supplied id order.
    def db_fallback_ordered(ids)
      records = where(id: ids).includes(cache_includes).index_by { |r| r.id.to_s }
      ids.filter_map { |id| records[id.to_s] }
    end

    # Load missed ids from the DB, warm their cache keys, merge into hits.
    def load_missed_records(hits, missed_ids)
      return if missed_ids.empty?

      where(id: missed_ids).includes(cache_includes).each do |record|
        record.cache_self
        hits[record.id.to_s] = record
      end
    end

    # Rebuild an AR instance from a raw attribute hash parsed from Redis JSON.
    #
    # For every association symbol returned by +cache_includes+, if the hash
    # contains a matching key (e.g. "category"), the nested attributes are
    # instantiated via the association's own class and injected directly into
    # the association proxy target.  This prevents ActiveRecord from issuing an
    # extra SQL query the first time the association is read in a view.
    def hydrate(attrs)
      record = instantiate(attrs)
      Array(cache_includes).each do |assoc_name|
        assoc_attrs = attrs[assoc_name.to_s]
        next unless assoc_attrs

        reflection = reflect_on_association(assoc_name)
        next unless reflection

        assoc_record = reflection.klass.instantiate(assoc_attrs)
        record.association(assoc_name).target = assoc_record
      end
      record
    end
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------

  # Serialise this record — including any associations declared by the class —
  # into Redis under its individual cache key.
  def cache_self
    cache_key = "#{self.class.cache_prefix}:#{id}"
    self.class.redis_client.setex(
      cache_key,
      self.class::CACHE_TTL,
      to_json(include: self.class.cache_includes)
    )
  rescue Redis::BaseError => e
    Logger.new($stdout).warn("Redis error in cache_self: #{e.message}. Cache write failed.")
  end

  # Called automatically via after_save.
  # Refreshes the individual-record cache and busts model-specific collection keys.
  def sync_cache
    cache_self
    invalidate_related_caches
  end

  # Called automatically via after_destroy.
  # Removes this record's individual cache key plus any related collection keys.
  def invalidate_cache
    keys_to_delete = ["#{self.class.cache_prefix}:#{id}"]
    keys_to_delete.concat(related_cache_keys)
    self.class.redis_client.del(*keys_to_delete)
  rescue Redis::BaseError => e
    Logger.new($stdout).warn("Redis error in invalidate_cache: #{e.message}. Cache invalidation failed.")
  end

  private

  # Bust only the collection-level caches (not the record's own key).
  def invalidate_related_caches
    keys = related_cache_keys
    return if keys.empty?

    self.class.redis_client.del(*keys)
  rescue Redis::BaseError => e
    Logger.new($stdout).warn("Redis error in invalidate_related_caches: #{e.message}. Cache invalidation failed.")
  end

  # Override in the including model to return model-specific collection keys
  # that should be invalidated when this record is saved or destroyed.
  # The global ":all" key should NOT be included here — use fetch_multi_cached
  # with paginated ids instead of a monolithic collection cache.
  def related_cache_keys
    []
  end
end
