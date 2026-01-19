# frozen_string_literal: true

require 'sidekiq'

# Background worker for sending emails asynchronously
# Usage: EmailWorker.perform_async(user_id)
class EmailWorker
  include Sidekiq::Worker

  # Send welcome email to user
  # @param user_id [Integer] The ID of the user to send email to
  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    EmailService.send_welcome_email(user)
  end
end
