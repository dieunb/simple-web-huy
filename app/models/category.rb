# frozen_string_literal: true

# Model for Category
class Category < ActiveRecord::Base
  has_many :products
  validates :name, presence: true
  before_save :run_my_custom_validate

  def run_my_custom_validate
    return unless name.to_s.strip.length < 3

    errors.add(:name, 'is too short (minimum is 3 characters)')
  end
end
