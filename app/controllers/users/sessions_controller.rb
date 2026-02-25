class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # POST /login
  def create
    super
  end

  # DELETE /logout
  def destroy
    super
  end

  private

  # Called after successful login
  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully',
      user: {
        id: resource.id,
        email: resource.email,
        role: resource.role
      }
    }, status: :ok
  end

  # Called after logout
  def respond_to_on_destroy(_resource = nil)
    head :no_content
  end
end