# frozen_string_literal: true

require 'sidekiq'
require 'grpc'
require_relative '../../grpc/user_service_services_pb'

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
    logger.info("Calling gRPC for user: #{user_id}")
    host = ENV.fetch('GRPC_HOST', 'localhost:50051')
    stub = SimpleWebRpc::UserService::Stub.new(host, :this_channel_is_insecure)
    response = stub.get_user(SimpleWebRpc::GetUserRequest.new(user_id: user_id.to_i))

    return nil unless response.found

    user_struct = Struct.new(:id, :name, :email)
    user_struct.new(response.id, response.name, response.email)
  end
end
