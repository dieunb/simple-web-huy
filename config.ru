# frozen_string_literal: true

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'app/controllers/home_controller'
require 'app/controllers/users_controller'
require 'app/models/user'
require 'rack/session/cookie'

use Rack::Session::Cookie, 
  key:'rack.session',
  path: '/',
  secret: 'your_secret_key_0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

use Frack::Router do
  get '/' => 'home#show'
  get '/sign_up' => 'users#new'
  post '/sign_up' => 'users#create'
end

use OTR::ActiveRecord::ConnectionManagement
run Frack::Application
