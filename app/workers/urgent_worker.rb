# frozen_string_literal: true
require 'sidekiq'

class UrgentWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, retry: false
  def perform(user_id)
    sleep 0.5 
  end
end
