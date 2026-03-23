class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ErrorHandler
  include ApiResponder
  include Pundit

  before_action { set_user_by_token(:api_v1_user) }

  before_action :configure_permitted_parameters, if: :devise_token_auth_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :department_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :department_id])
  end

  def devise_token_auth_controller?
    defined?(DeviseTokenAuth) && is_a?(DeviseTokenAuth::ApplicationController)
  end
end
