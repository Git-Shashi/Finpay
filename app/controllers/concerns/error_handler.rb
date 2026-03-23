module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    rescue_from UnauthorizedError do |e|
      render json: { error: e.message }, status: :forbidden
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      render json: { error: e.message }, status: :forbidden
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end
  end
end
