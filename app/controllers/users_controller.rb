class UsersController < ApplicationController
  def index
    users = User.all
    render json: UserSerializer.new(users).serialize
  end

  def show
    if user
      render json: UserSerializer.new(user).serialize
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def create
    user = User.create!(user_params)
    render json: UserSerializer.new(user).serialize, status: :created
  end

  def update
    if user
      user.update!(user_params)
      render json: UserSerializer.new(user).serialize
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def destroy
    if user
      user.destroy
      head :no_content
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def user
    @user ||= User.find(params[:id])
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