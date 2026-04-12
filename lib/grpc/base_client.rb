# frozen_string_literal: true

require 'grpc'

module Grpc
  # Base client handling connection, error handling, and logging
  class BaseClient
    DEFAULT_HOST = "#{ENV.fetch('GRPC_HOST', 'localhost')}:#{ENV.fetch('GRPC_PORT', '50051')}".freeze

    class << self
      def stub_class
        raise NotImplementedError, 'Subclass must define stub_class'
      end

      def call(method_name, request)
        execute_call(method_name, request)
      rescue GRPC::BadStatus => e
        logger.error("[gRPC] #{service_name}##{method_name} failed: #{e.code} - #{e.details}")
        raise
      rescue StandardError => e
        logger.error("[gRPC] #{service_name}##{method_name} error: #{e.class} - #{e.message}")
        raise
      end

      private

      def execute_call(method_name, request)
        stub = create_stub
        logger.info("[gRPC] Calling #{service_name}##{method_name}")
        response = stub.public_send(method_name, request)
        logger.info("[gRPC] #{service_name}##{method_name} succeeded")
        response
      end

      def create_stub
        stub_class.new(DEFAULT_HOST, :this_channel_is_insecure)
      end

      def service_name
        stub_class.to_s.split('::')[-2]
      end

      def logger
        @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
      end
    end
  end
end
