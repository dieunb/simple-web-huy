# frozen_string_literal: true

module Frack
  # Base controller class that provides common functionality for all controllers
  class BaseController
    attr_reader :request, :session, :current_user, :flash_message

    include Pagy::Backend
    include Pagy::Frontend

    def initialize(env)
      @request = Rack::Request.new(env)
      @flash_message = request.session&.delete('flash')
      @current_user = User.find_by_id request.session['user_id']
    end

    def render(view)
      render_template('layouts/application') do
        render_template(view)
      end
    end

    def render_template(path, &block)
      template = Tilt::ErubiTemplate.new(file(path))
      template.render(self, &block)
    end

    def file(path)
      Dir[File.join('app', 'views', "#{path}.html.*")].first
    end
  end
end
