module Frack
  class BaseController
    attr_reader :request

    def initialize(env)
    end

    def render(view)
    end

    def render_template()
    end

    def file(path)
    end
  end
end