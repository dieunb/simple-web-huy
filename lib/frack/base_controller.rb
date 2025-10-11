module Frack
  class BaseController
    attr_reader :request, :session, :current_user

    def initialize(env)
      @request = Rack::Request.new(env)
      @flash_message = request.session&.delete('flash')
    end

    def render(view)
      render_template('layouts/application') do
        render_template(view)
      end 
    end
  end
end