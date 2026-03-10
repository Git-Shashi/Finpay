class DepartmentsController < ApplicationController
  def index
    departments = Department.all
    render json: DepartmentSerializer.new(departments).serialize
  end

  def show
    if department
      render json: DepartmentSerializer.new(department).serialize
    else
      render json: { error: 'Department not found' }, status: :not_found
    end
  end

  def create
    department = Department.create!(department_params)
    render json: DepartmentSerializer.new(department).serialize, status: :created
  end

  def update
    if department
      department.update!(department_params)
      render json: DepartmentSerializer.new(department).serialize
    else
      render json: { error: 'Department not found' }, status: :not_found
    end
  end

  def destroy
    if department
      department.destroy
      head :no_content
    else
      render json: { error: 'Department not found' }, status: :not_found
    end
  end

  private

  def department
    @department ||= Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end
end