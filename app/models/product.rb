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

    def find_by_brand_cached(brand)
      ids = where(brand: brand).pluck(:id)
      fetch_multi_cached(ids)
    end

    def find_by_category_cached(category_id)
      ids = where(category_id: category_id).pluck(:id)
      fetch_multi_cached(ids)
    end
  end

  private

  # Collection keys that must be invalidated when this product changes.
  # NOTE: We no longer maintain a monolithic ":all" key.
  #       Pagination uses fetch_multi_cached(ids) so only individual
  #       record keys need to be managed here.
  def related_cache_keys
    keys = []
    keys << "#{self.class.cache_prefix}:brand:#{brand}"          if brand
    keys << "#{self.class.cache_prefix}:category:#{category_id}" if category_id
    keys
  end
end
