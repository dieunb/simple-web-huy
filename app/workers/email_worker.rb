# frozen_string_literal: true

require 'sidekiq'
require_relative '../../lib/grpc/client'

# Background worker for sending emails asynchronously
class EmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(user_id)
    send_email_if_found(fetch_user_via_grpc(user_id), user_id)
  rescue GRPC::BadStatus, StandardError => e
    handle_error(user_id, e)
  end

  private

  def send_email_if_found(user, user_id)
    if user
      WelcomeEmailService.send_welcome_email(user)
      logger.info("Sent welcome email success via gRPC: #{user_id}")
    else
      logger.info("User not found via gRPC: #{user_id}")
    end
  end

  def handle_error(user_id, error)
    logger.error("Error in EmailWorker for user #{user_id}: #{error.class} - #{error.message}")
    raise unless error.is_a?(GRPC::BadStatus)
  end

  def fetch_user_via_grpc(user_id)
    response = Grpc::Client.user.get_user(user_id)
    return nil unless response.found

    user_struct = Struct.new(:id, :name, :email)
    user_struct.new(response.id, response.name, response.email)
  end
end
