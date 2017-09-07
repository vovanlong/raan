class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @products = Product.all
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render :show, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def show
    
  end

  def update
    @product.update_attributes(product_params)
    head :ok
  end

  def destroy 
    @product.destroy 
    head :ok
  end

  private 
    def set_product 
      @product = Product.find_by_id(params[:id])
      if @product.nil? 
        render json: { message: 'Not found'}, status: :not_found
      end
    end

    def product_params
      params.permit(:name, :code, :category, :default_imported_price, :default_sale_price)
    end
end