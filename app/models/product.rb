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
  # Product-specific class methods
  # ---------------------------------------------------------------------------
  class << self
    # Embed the :category association in every cached payload so that
    # product.category.name in views never triggers a second SQL query.
    def cache_includes
      :category
    end

    def find_cached!(id)
      product = find_cached(id)
      raise ActiveRecord::RecordNotFound, "Couldn't find Product with 'id'=#{id}" unless product

      product
    end

    def all_cached
      fetch_collection_cache("#{cache_prefix}:all") { all.to_a }
    end

    def find_by_brand_cached(brand)
      fetch_collection_cache("#{cache_prefix}:brand:#{brand}") { where(brand: brand).to_a }
    end

    def find_by_category_cached(category_id)
      fetch_collection_cache("#{cache_prefix}:category:#{category_id}") { where(category_id: category_id).to_a }
    end
  end

  private

  # Tell Cacheable which collection keys belong to this product so they get
  # busted automatically on save/destroy.
  def related_cache_keys
    keys = ["#{self.class.cache_prefix}:all"]
    keys << "#{self.class.cache_prefix}:brand:#{brand}"            if brand
    keys << "#{self.class.cache_prefix}:category:#{category_id}"   if category_id
    keys
  end
end
