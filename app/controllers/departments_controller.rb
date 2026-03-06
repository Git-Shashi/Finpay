class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]

  def index
    departments = Department.all
    render json: DepartmentSerializer.new(departments).serialize
  end

  def show
    render json: DepartmentSerializer.new(@department).serialize
  end

  def create
    department = Department.create!(department_params)
    render json: DepartmentSerializer.new(department).serialize, status: :created
  end

  def update
    @department.update!(department_params)
    render json: DepartmentSerializer.new(@department).serialize
  end

  def destroy
    @department.destroy
    head :no_content
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
