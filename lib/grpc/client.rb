# frozen_string_literal: true

require_relative 'base_client'
require_relative '../proto/user_service_services_pb'

module Grpc
  # Centralized client for accessing gRPC services
  module Client
    module_function

    def user
      @user ||= UserClient
    end

    # Add more service clients here as needed:
    # def order
    #   @order ||= OrderClient
    # end
  end

  # Client for UserService
  class UserClient < BaseClient
    class << self
      def stub_class
        SimpleWebRpc::UserService::Stub
      end

      def get_user(user_id)
        request = SimpleWebRpc::GetUserRequest.new(user_id: user_id.to_i)
        call(:get_user, request)
      end
    end
  end
end
