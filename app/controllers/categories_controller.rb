class CategoriesController < ApplicationController
  def index
    render json: CategorySerializer.new(Category.all).serialize
  end

  def show
    if category
      render json: CategorySerializer.new(category).serialize
    else
      render json: { error: 'Category not found' }, status: :not_found
    end
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: CategorySerializer.new(category).serialize, status: :created
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if category
      if category.update(category_params)
        render json: CategorySerializer.new(category).serialize
      else
        render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Category not found' }, status: :not_found
    end
  end

  def destroy
    if category
      category.destroy
      head :no_content
    else
      render json: { error: 'Category not found' }, status: :not_found
    end
  end

  private

  def category
    return @category if defined?(@category)

    @category = Category.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end