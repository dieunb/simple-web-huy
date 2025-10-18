# frozen_string_literal: true

# Controller for Category
class CategoriesController < Frack::BaseController
  include Pagy::Backend

  def index
    unless current_user
      request.session['flash'] = 'You must sign in to continue'
      return [[], 302, { 'location' => '/' }]
    end

    page = request.params['page'] || 1
    @pagy, @categories = pagy(Category.order(:id), page: page)
    render 'categories/index'
  end

  def new
    unless current_user
      request.session['flash'] = 'You must sign in to continue'
      return [[], 302, { 'location' => '/' }]
    end
    render 'categories/new'
  end

  def create
    name = request.params['name']
    flash_mess, location = creation_outcome(name)

    request.session['flash'] = flash_mess
    [[], 302, { 'location' => location }]
  end

  private
  
  def creation_outcome(name)
    if name.to_s.strip.empty?
      ['Name cannot be blank', '/categories/new']
    elsif Category.new(name: name).save
      ['Category created', '/categories']
    else
      ['Create failed', '/categories/new']
    end
  end
end
