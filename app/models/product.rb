# frozen_string_literal: true

require 'redis'

# Model for Product
class Product < ActiveRecord::Base
  belongs_to :category
  validates :name, presence: true, length: { minimum: 3 }

  CACHE_PREFIX = 'product'
  CACHE_TTL = 3600 # 1 hour

  after_save    :sync_cache
  after_destroy :invalidate_cache

  class << self
    def redis_client
      @redis_client ||= Redis.new(url: redis_url)
    end

    # Returns a persisted-like AR instance from Redis, falling back to the DB.
    def find_cached(id)
      cache_key = "#{CACHE_PREFIX}:#{id}"
      cached_data = redis_client.get(cache_key)

      return instantiate(JSON.parse(cached_data)) if cached_data

      # Cache miss: load from DB, populate Redis, return the real record
      product = find_by(id: id)
      return nil unless product

      redis_client.setex(cache_key, CACHE_TTL, product.to_json(include: :category))
      product
    rescue Redis::BaseError => e
      Rails.logger.warn("Redis error: #{e.message}. Falling back to DB.")
      find_by(id: id)
    end

    def find_cached!(id)
      product = find_cached(id)
      raise ActiveRecord::RecordNotFound, "Couldn't find Product with 'id'=#{id}" unless product

      product
    end

    def all_cached
      cache_key = "#{CACHE_PREFIX}:all"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = all.to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Rails.logger.warn("Redis error: #{e.message}. Falling back to DB.")
      all.to_a
    end

    def find_by_brand_cached(brand)
      cache_key = "#{CACHE_PREFIX}:brand:#{brand}"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = where(brand: brand).to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Rails.logger.warn("Redis error: #{e.message}. Falling back to DB.")
      where(brand: brand).to_a
    end

    def find_by_category_cached(category_id)
      cache_key = "#{CACHE_PREFIX}:category:#{category_id}"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = where(category_id: category_id).to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Rails.logger.warn("Redis error: #{e.message}. Falling back to DB.")
      where(category_id: category_id).to_a
    end

    private

    def redis_url
      ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
    end
  end

  def cache_self
    cache_key = "#{self.class::CACHE_PREFIX}:#{id}"
    self.class.redis_client.setex(cache_key, self.class::CACHE_TTL, to_json(include: :category))
  rescue Redis::BaseError => e
    Rails.logger.warn("Redis error: #{e.message}. Cache write failed.")
  end

  private

  # Called after every save (create + update).
  def sync_cache
    cache_self
    invalidate_related_caches
  end

  # Called after destroy — remove every cache key that referenced this product.
  def invalidate_cache
    keys_to_delete = ["#{self.class::CACHE_PREFIX}:#{id}"]
    keys_to_delete.concat(related_cache_keys)
    self.class.redis_client.del(*keys_to_delete)
  rescue Redis::BaseError => e
    Rails.logger.warn("Redis error: #{e.message}. Cache invalidation failed.")
  end

  def related_cache_keys
    keys = ["#{self.class::CACHE_PREFIX}:all"]
    keys << "#{self.class::CACHE_PREFIX}:brand:#{brand}" if brand
    keys << "#{self.class::CACHE_PREFIX}:category:#{category_id}" if category_id
    keys
  end

  def invalidate_related_caches
    self.class.redis_client.del(*related_cache_keys)
  rescue Redis::BaseError => e
    Rails.logger.warn("Redis error: #{e.message}. Cache invalidation failed.")
  end
end
