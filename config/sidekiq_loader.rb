# frozen_string_literal: true

# Loader file for Sidekiq to require all necessary files
# This ensures models, services, and workers are available when Sidekiq processes jobs

require 'dotenv/load'

$LOAD_PATH.unshift << '.'

require 'lib/frack'
require 'config/initializers/sidekiq'

# Load models
require 'app/models/user'
require 'app/models/category'
require 'app/models/product'

# Load services
require 'app/services/email_service'

# Load workers
require 'app/workers/email_worker'
