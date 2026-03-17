module Api
  module V1
    class CategoriesController < Api::V1::BaseController
  def index
    render_success CategorySerializer.new(Category.all).serialize
  end

  def show
    render_success CategorySerializer.new(category).serialize
  end

  def create
    category = Category.create!(category_params)
    render_created CategorySerializer.new(category).serialize
  end

  def update
    category.update!(category_params)
    render_success CategorySerializer.new(category).serialize
  end

  def destroy
    category.destroy
    render_no_content
  end

  private

  def category
    @category ||= Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
    end
  end
end
