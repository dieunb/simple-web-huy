# frozen_string_literal: true

require 'sidekiq'

# UrgentWorker handles critical priority background jobs
class UrgentWorker
  include Sidekiq::Worker

  sidekiq_options queue: :critical, retry: false
  def perform(_user_id)
    sleep 0.5
  end
end
