# frozen_string_literal: true

# Controller for Product
class ProductsController < Frack::BaseController
  def index
    return require_authentication unless current_user

    @pagy, @products = setup_pagination(Product.includes(:category).order(:id))
    render 'products/index'
  end

  def new
    render 'products/new'
  end

  def create
    new_product = Product.new(product_params)

    if new_product.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  def destroy
    return require_authentication unless current_user

    return product_not_found unless find_product

    product_name = @product.name
    request.session['flash'] = if @product.destroy
                                 "Product '#{product_name}' deleted"
                               else
                                 'Delete failed'
                               end

    [[], 302, { 'location' => '/products' }]
  end


  private

  def find_product
    product_id = request.params['id']
    @product = Product.find_by(id: product_id)
  end

  def product_not_found
    request.session['flash'] = 'Product not found'
    [[], 302, { 'location' => '/products' }]
  end

  def product_params
    request.params.slice(
      'name',
      'brand',
      'category_id',
      'year',
      'price'
    )
  end

  def handle_successful_creation
    request.session['flash'] = 'Product created'
    [[], 302, { 'location' => '/products' }]
  end

  def handle_failed_creation
    request.session['flash'] = 'Create failed'
    [[], 302, { 'location' => '/products/new' }]
  end
end
