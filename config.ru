# frozen_string_literal: true

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'app/controllers/home_controller'

use Frack::Router do
  get '/' => 'home#show'
end

run Frack::Application
