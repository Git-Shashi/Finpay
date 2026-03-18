module Api
  module V1
    class DepartmentsController < Api::V1::BaseController
      def index
        render_success DepartmentSerializer.new(Department.all).serialize
      end

      def show
        render_success DepartmentSerializer.new(department).serialize
      end

      def create
        department = Department.create!(department_params)
        render_created DepartmentSerializer.new(department).serialize
      end

      def update
        department.update!(department_params)
        render_success DepartmentSerializer.new(department).serialize
      end

      def destroy
        department.destroy
        render_no_content
      end

      private

      def department
        @department ||= Department.find(params[:id])
      end

      def department_params
        params.require(:department).permit(:name)
      end
    end
  end
end
