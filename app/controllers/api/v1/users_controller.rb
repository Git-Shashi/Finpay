module Api
  module V1
    class UsersController < Api::V1::BaseController
  def index
    render_success UserSerializer.new(User.all).serialize
  end

  def show
    render_success UserSerializer.new(user).serialize
  end

  def create
    user = User.create!(user_params)
    render_created UserSerializer.new(user).serialize
  end

  def update
    user.update!(user_params)
    render_success UserSerializer.new(user).serialize
  end

  def destroy
    user.destroy
    render_no_content
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
end
