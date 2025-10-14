# frozen_string_literal: true

# HomeController to handle the home page rendering
class HomeController < Frack::BaseController
  def index
    render 'home/show'
  end
end
