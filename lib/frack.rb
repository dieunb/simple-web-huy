# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

require 'rack'
require 'tilt'
require 'erb'
require 'active_record'
require 'pg'
require 'otr-activerecord'
require 'dotenv/load'

OTR::ActiveRecord.configure_from_file! 'config/database.yml'
OTR::ActiveRecord.establish_connection!

# Frack web framework module
module Frack
  autoload :Router, 'frack/router'
  autoload :BaseController, 'frack/base_controller'
  autoload :Application, 'frack/application'
end
