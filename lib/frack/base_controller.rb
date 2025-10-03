module Frack
  class BaseController
    attr_reader :request

    def initialize(env)
    @request = Rack::Request.new(env)
    @flash_message = request.session&.delete('flash')
    end

    def render(view)
    end

    def render_template()
    end

    def file(path)
    end
  end
end