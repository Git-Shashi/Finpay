class UsersController < ApplicationController
  def index
    users = User.all
    render json: UserSerializer.new(users).serialize
  end

  def show
    render json: UserSerializer.new(user).serialize
  end

  def create
    user = User.create!(user_params)
    render json: UserSerializer.new(user).serialize, status: :created
  end

  def update
    user.update!(user_params)
    render json: UserSerializer.new(user).serialize
  end

  def destroy
    user.destroy
    head :no_content
  end

  private

  def user
    return @user if defined?(@user)

    @user = User.find_by(id: params[:id])
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
