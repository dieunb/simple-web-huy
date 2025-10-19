# frozen_string_literal: true

$LOAD_PATH.unshift << '.'
require 'lib/frack'
require 'app/models/category'
require 'app/models/product'
require 'faker'


100.times do
  Category.create(name: Faker::Commerce.brand)
end

50.times do
  Product.create(name: Faker::Commerce.product_name)
end