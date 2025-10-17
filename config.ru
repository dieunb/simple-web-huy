# frozen_string_literal: true

require 'dotenv/load'

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'app/controllers/home_controller'
require 'app/controllers/users_controller'
require 'app/controllers/sessions_controller'
require 'app/controllers/categories_controller'
require 'app/models/category'
require 'app/models/user'
require 'rack/session/cookie'

use Rack::Session::Cookie,
    key: 'rack.session',
    path: '/',
    secret: ENV.fetch('SESSION_SECRET', nil)

use Frack::Router do
  get '/' => 'home#show'
  get '/sign_up' => 'users#new'
  post '/sign_up' => 'users#create'
  get '/sign_in' => 'sessions#new'
  post '/sign_in' => 'sessions#create'
  delete '/sign_out' => 'sessions#destroy'
  get '/categories' => 'categories#index'
  get '/categories/new' => 'categories#new'
  post '/categories' => 'categories#create'
end

use OTR::ActiveRecord::ConnectionManagement
run Frack::Application
