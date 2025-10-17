# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

require 'rack'
require 'tilt'
require 'erb'
require 'erubi'
require 'active_record'
require 'pg'
require 'otr-activerecord'
require 'pagy'
require 'pagy/extras/overflow'
require 'pagy/extras/bootstrap'
require 'dotenv/load'

OTR::ActiveRecord.configure_from_file! 'config/database.yml'
OTR::ActiveRecord.establish_connection!

# Pagy defaults
Pagy::DEFAULT[:items] = 10 # items per page
Pagy::DEFAULT[:size]  = 9  # nav bar links
Pagy::DEFAULT[:overflow] = :last_page

# Frack web framework module
module Frack
  autoload :Router, 'frack/router'
  autoload :BaseController, 'frack/base_controller'
  autoload :Application, 'frack/application'
end
