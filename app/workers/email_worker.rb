# frozen_string_literal: true

require 'sidekiq'

# Background worker for sending emails asynchronously
class EmailWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    WelcomeEmailService.send_welcome_email(user)
  end
end
