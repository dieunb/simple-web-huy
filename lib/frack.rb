$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rack'
require 'tilt'
require 'erb'
require 'active_record'
require 'pg'
require 'otr-activerecord'

OTR::ActiveRecord.configure_from_file!('config/database.yml')
OTR::ActiveRecord.establish_connection!

module Frack
  autoload :Application, 'frack/application'
  autoload :BaseController,  'frack/base_controller'
  autoload :Router, 'frack/router'  
end
