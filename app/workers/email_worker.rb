# frozen_string_literal: true

require 'sidekiq'

# Background worker for sending emails asynchronously
class EmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(user_id)
    user = User.find_by(id: user_id)
    if user
      WelcomeEmailService.send_welcome_email(user)
      logger.info("Sent welcome email success: #{user_id}")
    else
      logger.info("User not found: #{user_id}")
    end
  end
end
