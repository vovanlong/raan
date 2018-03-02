class CategoriesController < ApplicationController
    before_action :category_params ,only: [:create, :update]
    before_action :set_category ,only: [:destroy, :update, :show]
    def index
        @categories, @total = Category.get_pagination(params[:page], params[:per_page], params[:search_text])
    end

    def create
        @category = Category.new(category_params)
        if @category.save
        render :show, status: :created, location: @category
        else
        render json: @category.errors, status: :unprocessable_entity
        end
    end

    def show
    
    end

    def update
        @category.update_attributes(category_params)
        render :show, status: :updated, location: @category
    end

    def destroy
        @category.destroy
        render json: { permanently_delete: true }
    end

    private 
    def category_params
        params.permit(:category)
    end

    def set_category
      @category = Category.find_by_id(params[:id])
      if @category.nil? 
        render json: { message: 'Not found'}, status: :not_found
      end
    end
end
