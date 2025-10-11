# frozen_string_literal: true

module Frack
  # Router class for handling HTTP routes and method overrides
  class Router
    attr_reader :app, :routes

    def initialize(app, &block)
      @app = app
      @routes = {}
      instance_eval(&block) if block_given?
    end

    def call(env)
      path = env['PATH_INFO']
      http_method = resolve_http_method(env)
      env['REQUEST_METHOD'] = http_method

      if (mapping = routes[path + http_method])
        env.merge!(controller_action(mapping))
        app.call(env)
      else
        Rack::Response.new('Not found', 404).finish
      end
    end

    def resolve_http_method(env)
      method = env['REQUEST_METHOD']

      if method == 'POST'
        request = Rack::Request.new(env)
        override_method = request.params['_method']
        method = override_method.upcase if override_method && %w[DELETE PATCH PUT].include?(override_method.upcase)
      end

      method
    end

    def controller_action(mapping)
      Hash[%w[controller action].zip(mapping.split('#'))]
    end

    def push(route)
      routes.merge!("#{route.keys.first}PUSH" => route.values.first)
    end

    def delete(route)
      routes.merge!("#{route.keys.first}DELETE" => route.values.first)
    end

    def patch(route)
      routes.merge!("#{route.keys.first}PATCH" => route.values.first)
    end

    def post(route)
      routes.merge!("#{route.keys.first}POST" => route.values.first)
    end

    def get(route)
      routes.merge!("#{route.keys.first}GET" => route.values.first)
    end
  end
end
