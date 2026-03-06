class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    users = User.all
    render json: UserSerializer.new(users).serialize
  end

  def show
    user = User.find(params[:id])
    render json: UserSerializer.new(user).serialize
  end

  def create
    user = User.create!(user_params)
    render json: UserSerializer.new(user).serialize, status: :created
  end

  def update
    user = User.find(params[:id])
    user.update!(user_params)
    render json: UserSerializer.new(user).serialize
  end

  def destroy
    User.find(params[:id]).destroy
    head :no_content
  end

  private
  def set_user
  @user = User.find(params[:id])
  end

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
