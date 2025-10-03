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

      def put(route) 
        self.routes
            .merge!(route.keys.first + 'PUT' => route.values.first)
      end

      def get(route)
        self.routes
            .merge!(route.keys.first + 'GET' => route.values.first)
      end

      def post(route)
        self.routes
            .merge!(route.keys.first + 'POST' => route.values.first)
      end

      def delete(route)
        self.routes
            .merge!(route.keys.first + 'DELETE' => route.values.first)  
      end

      def get(route)
        self.routes
            .merge!(route.keys.first + 'GET' => route.values.first)
      end
  end
end 