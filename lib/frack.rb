$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rack'
require 'tilt'
require 'erb'
require 'active_record'
require 'pg'