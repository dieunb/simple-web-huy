$LOAD_PATH.unshift << '.'
require 'lib/frack'

use OTR::ActiveRecord::ConnectionManagement
run Frack::Application.new