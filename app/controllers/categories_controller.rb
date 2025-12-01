# frozen_string_literal: true

# Controller for Category
class CategoriesController < Frack::BaseController
  def index
    return require_authentication unless current_user

    @pagy, @categories = setup_pagination(Category.order(:id))
    render 'categories/index'
  end

  def new
    return require_authentication unless current_user

    render 'categories/new'
  end

  def show
    return require_authentication unless current_user

    return category_not_found unless find_category

    @pagy, @products = setup_pagination(@category.products.order(:id))
    render 'categories/show'
  end

  def create
    name = request.params['name']
    flash_mess, location = creation_outcome(name)

    request.session['flash'] = flash_mess
    [[], 302, { 'location' => location }]
  end

  def destroy
    return require_authentication unless current_user

    return category_not_found unless find_category
    category_name = @category.name
    if @category.destroy
      request.session['flash'] = "Category '#{category_name}' deleted"
    else
      request.session['flash'] = "Failed to delete"
    end

    [[], 302, { 'location' => '/categories' }]
  end

  private

  def find_category
    category_id = request.params['id']
    @category = Category.find_by(id: category_id)
  end

  def category_not_found
    request.session['flash'] = 'Category not found'
    [[], 302, { 'location' => '/categories' }]
  end

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
