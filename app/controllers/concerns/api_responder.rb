module ApiResponder
  extend ActiveSupport::Concern

  private

  def render_success(data, status: :ok)
    render json: data, status: status
  end

  def render_created(data)
    render json: data, status: :created
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_no_content
    head :no_content
  end

  def render_message(message, status: :ok)
    render json: { message: message }, status: status
  end
end
