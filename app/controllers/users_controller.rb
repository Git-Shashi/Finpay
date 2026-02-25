class UsersController < ApplicationController
  def index
    render json: User.all
  end

  def show
    render json: User.find(params[:id])
  end

  def create
    user = User.create!(user_params)
    render json: user, status: :created
  end

  def update
    user = User.find(params[:id])
    user.update!(user_params)
    render json: user
  end

  def destroy
    User.find(params[:id]).destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :department_id,
      :role
    )
  end
end