module Frack
  class BaseController
    attr_reader :request, :session, :current_user

    def initialize(env)
      @request = Rack::Request.new(env)
      @flash_message = request.session&.delete('flash')
    end
  end
end