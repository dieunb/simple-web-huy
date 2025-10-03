module Frack
  class BaseController
    attr_reader :request

    def initialize(env)
    @request = Rack::Request.new(env)
    @flash_message = request.session&.delete('flash')
    end

    def render(view)
      render_template('layouts/application') do
        render_template(view)
      end
    end

    def render_template()
    end

    def file(path)
    end
  end
end