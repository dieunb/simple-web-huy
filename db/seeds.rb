$LOAD_PATH.unshift << '.'
require 'lib/frack'
require 'app/models/category'
require 'faker'


100.times do 
  Category.create(name: Faker::Commerce.brand)
end
