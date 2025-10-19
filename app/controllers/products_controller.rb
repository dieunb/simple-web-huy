# frozen_string_literal: true

# Controller for Product
class ProductsController < Frack::BaseController
  def index
    unless current_user
      request.session['flash'] = 'You must sign in to continue'
      return [[], 302, { 'location' => '/' }]
    end

    page = request.params['page'] || 1
    @pagy, @products = pagy(Product.includes(:category).order(:id), page: page)
    render 'products/index'
  end

  def new
    render 'products/new'
  end

  def create
    product_params = request.params.slice(
      'name',
      'brand',
      'category_id',
      'year',
      'price'
    )

    new_product = Product.new(product_params)

    if new_product.save
      request.session['flash'] = 'Product created'
      [[], 302, { 'location' => '/products' }]
    else
      request.session['flash'] = 'Create failed'
      [[], 302, { 'location' => '/products/new' }]
    end
  end
end