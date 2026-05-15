# frozen_string_literal: true

require_relative '../../lib/cacheable'

# Model for Product
class Product < ActiveRecord::Base
  include Cacheable

  belongs_to :category
  validates :name, presence: true, length: { minimum: 3 }

  CACHE_PREFIX = 'product'
  CACHE_TTL    = 3600 # 1 hour

  # ---------------------------------------------------------------------------
  # Product-specific cached finders (class level)
  # ---------------------------------------------------------------------------
  class << self
    def find_cached!(id)
      product = find_cached(id)
      raise ActiveRecord::RecordNotFound, "Couldn't find Product with 'id'=#{id}" unless product

      product
    end

    def all_cached
      cache_key   = "#{cache_prefix}:all"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = all.to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in all_cached: #{e.message}. Falling back to DB.")
      all.to_a
    end

    def find_by_brand_cached(brand)
      cache_key   = "#{cache_prefix}:brand:#{brand}"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = where(brand: brand).to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in find_by_brand_cached: #{e.message}. Falling back to DB.")
      where(brand: brand).to_a
    end

    def find_by_category_cached(category_id)
      cache_key   = "#{cache_prefix}:category:#{category_id}"
      cached_data = redis_client.get(cache_key)
      return JSON.parse(cached_data).map { |data| instantiate(data) } if cached_data

      products = where(category_id: category_id).to_a
      redis_client.setex(cache_key, CACHE_TTL, products.to_json(include: :category))
      products
    rescue Redis::BaseError => e
      Logger.new($stdout).warn("Redis error in find_by_category_cached: #{e.message}. Falling back to DB.")
      where(category_id: category_id).to_a
    end
  end

  private

  # Tell Cacheable which collection keys belong to this product so they get
  # busted automatically on save/destroy.
  def related_cache_keys
    keys = ["#{self.class.cache_prefix}:all"]
    keys << "#{self.class.cache_prefix}:brand:#{brand}"       if brand
    keys << "#{self.class.cache_prefix}:category:#{category_id}" if category_id
    keys
  end
end
