module Frack
  class Router
    attr_reader :routes, :app 
      def initialize(app, &block)
        @app = app
        @routes = {}
        instance_eval(&block) if block_given?
      end

      def call(env)
        path = env['PATH_INFO']
        http_method = env['REQUEST_METHOD']
      
      if http_method == 'POST'
        request = Rack::Request.new(env)
        override_method = request.params['_method']
        if override_method && ['DELETE', 'PATCH', 'PUT'].include?(override_method.upcase)
          http_method = override_method.upcase
        end
      end
      
      env['REQUEST_METHOD'] = http_method
      
      if mapping = routes[path+http_method]
        env.merge!(controller_action(mapping))
        app.call(env)
      else
        Rack::Response.new('Not found', 404).finish
      end
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