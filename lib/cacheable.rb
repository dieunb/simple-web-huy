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
#   end
#
# The including class MUST define:
#   CACHE_PREFIX  – string key namespace used in Redis (e.g. "product")
#   CACHE_TTL     – integer TTL in seconds
#
# Class methods added:
#   redis_client              – memoised Redis connection
#   cache_prefix              – returns the model's CACHE_PREFIX constant
#   find_cached(id)           – cache-aware find, falls back to DB on miss/error
#
# Instance methods added:
#   cache_self                – writes this record to Redis
#   sync_cache                – updates record cache + invalidates collection caches
#   invalidate_cache          – removes all cache keys for this record
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

    # Return a record by id, preferring the Redis cache.
    # Falls back to the database on a cache miss or a Redis error.
    def find_cached(id)
      cache_key   = "#{cache_prefix}:#{id}"
      cached_data = redis_client.get(cache_key)

      return instantiate(JSON.parse(cached_data)) if cached_data

      # Cache miss: load from DB, populate Redis, return the real record.
      record = find_by(id: id)
      return nil unless record

      redis_client.setex(cache_key, self::CACHE_TTL, record.to_json(include: :category))
      record
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in find_cached: #{e.message}. Falling back to DB.")
      find_by(id: id)
    end
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------

  # Write this record's JSON representation into Redis.
  def cache_self
    cache_key = "#{self.class.cache_prefix}:#{id}"
    self.class.redis_client.setex(cache_key, self.class::CACHE_TTL, to_json(include: :category))
  rescue Redis::BaseError => e
    Logger.new($stdout).warn("Redis error in cache_self: #{e.message}. Cache write failed.")
  end

  # Called automatically via after_save.
  # Refreshes the individual-record cache and busts collection caches.
  def sync_cache
    cache_self
    invalidate_related_caches
  end

  # Called automatically via after_destroy.
  # Removes every cache key that referenced this record.
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
    self.class.redis_client.del(*related_cache_keys)
  rescue Redis::BaseError => e
    Logger.new($stdout).warn("Redis error in invalidate_related_caches: #{e.message}. Cache invalidation failed.")
  end

  # Subclasses may override this to add model-specific collection keys.
  def related_cache_keys
    []
  end
end
