# frozen_string_literal: true

# Model for Product
class Product < ActiveRecord::Base
  belongs_to :category
  validates :name, presence: true, length: { minimum: 3 }
end
