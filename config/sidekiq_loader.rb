# frozen_string_literal: true

require 'dotenv/load'

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'config/initializers/sidekiq'

# Load models
require 'app/models/user'
require 'app/models/category'
require 'app/models/product'

# Load services
require 'app/services/welcome_email_service'

# Load workers
require 'app/workers/email_worker'
require 'app/workers/urgent_worker'
