# frozen_string_literal: true

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'app/controllers/home_controller'
require 'app/controllers/categories_controller'
require 'app/models/category'

use Frack::Router do
  get '/' => 'home#show'
  get '/categories' => 'categories#index'
  get '/categories/new' => 'categories#new'
  post '/categories' => 'categories#create'
end

run Frack::Application
