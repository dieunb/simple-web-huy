# frozen_string_literal: true

# HomeController to handle the home page rendering
class HomeController < Frack::BaseController
  def show
    render 'home/show'
  end
end
