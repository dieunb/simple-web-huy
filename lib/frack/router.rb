module Frack
  class Router
    attr_reader :routes, :app 
      def initialize(app)
        @app = app
        @routes = {}
        instance_eval(&block) if block_given?
      end

      def call(env)
        
      end

      def controller_action(mapping)
      Hash[%w(controller action).zip mapping.split('#')]
      end