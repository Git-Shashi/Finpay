class CategoriesController < ApplicationController
  def index
    render json: Category.all
  end

  def show
    render json: Category.find(params[:id])
  end

  def create
    category = Category.create!(category_params)
    render json: category, status: :created
  end

  def update
    category = Category.find(params[:id])
    category.update!(category_params)
    render json: category
  end

  def destroy
    Category.find(params[:id]).destroy
    head :no_content
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end