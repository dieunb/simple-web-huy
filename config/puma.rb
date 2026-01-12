require 'logger'

workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

log_requests true
custom_logger Logger.new(STDOUT)

log_formatter do |str|
  "[#{Process.pid}] [#{Socket.gethostname}] #{Time.now}: #{str}"
end

on_worker_boot do
  # Configuration for frameworks like Rails might be placed here if running in cluster mode
  if defined?(ActiveRecord)
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end