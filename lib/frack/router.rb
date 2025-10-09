module Frack
  class Router
    attr_reader :app, :routes

    def initialize(app, &block)
      @app = app
      @routes = {}
      instance_eval(&block) if block_given?
    end
    
    def call(env)
    end

  end
end