class DepartmentsController < ApplicationController
  def index
    render json: Department.all
  end

  def show
    render json: Department.find(params[:id])
  end

  def create
    department = Department.create!(department_params)
    render json: department, status: :created
  end

  def update
    department = Department.find(params[:id])
    department.update!(department_params)
    render json: department
  end

  def destroy
    Department.find(params[:id]).destroy
    head :no_content
  end

  private

  def department_params
    params.require(:department).permit(:name)
  end
end