# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'dotenv/load'
require 'yaml'

# Reuse existing app boot logic to avoid duplicating config/DB setup
require_relative '../config/sidekiq_loader'

# Load gRPC files
require_relative 'proto/user_service_services_pb'

module SimpleWebRpc
  # gRPC service implementation for user operations
  class UserServiceImpl < SimpleWebRpc::UserService::Service
    def get_user(request, _unused_call)
      user = ::User.find_by(id: request.user_id)
      build_response(user)
    end

    private

    def build_response(user)
      return not_found_response unless user

      SimpleWebRpc::GetUserResponse.new(
        id: user.id,
        name: user.email.split('@').first,
        email: user.email,
        found: true
      )
    end

    def not_found_response
      SimpleWebRpc::GetUserResponse.new(id: 0, name: '', email: '', found: false)
    end
  end
end

def main
  addr = '0.0.0.0:50051'
  server = GRPC::RpcServer.new
  server.add_http2_port(addr, :this_port_is_insecure)
  server.handle(SimpleWebRpc::UserServiceImpl)
  puts "gRPC UserService listening on #{addr}"
  server.run_till_terminated
end

main if $PROGRAM_NAME == __FILE__
