$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rack'
require 'tilt'
require 'erb'
require 'activerecord'
require 'pg'

module Frack
  autoload :Application, 'frack/application'
  autoload :BaseController,  'frack/base_controller'
  autoload :Router, 'frack/router'  
end
