module Api
  module V1
    class CategoriesController < Api::V1::BaseController
      before_action :authenticate_user!

      def index
        authorize Category
        render_success CategorySerializer.new(Category.all).serialize
      end

      def show
        authorize category
        render_success CategorySerializer.new(category).serialize
      end

      def create
        authorize Category
        category = Category.create!(category_params)
        render_created CategorySerializer.new(category).serialize
      end

      def update
        authorize category
        category.update!(category_params)
        render_success CategorySerializer.new(category).serialize
      end

      def destroy
        authorize category
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
end
