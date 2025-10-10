# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

require 'rack'
require 'tilt'
require 'erb'
require 'active_record'
require 'pg'

# Frack web framework module
module Frack
  autoload :Router, 'frack/router'
end