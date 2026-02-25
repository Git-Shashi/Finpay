class TenantSwitcher
  PUBLIC_PATHS = %w[
    /companies
    /health
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    # Skip tenant switching for public routes
    return @app.call(env) if public_path?(request.path)

    subdomain = request.headers['HTTP_X_COMPANY_ID'] || request.headers['X-Company-Id']

    # If no subdomain is present, tenant cannot be resolved
    return tenant_not_found("X-Company-Id header missing") if subdomain.blank?

    schema_name = "company_#{subdomain}"
    company = Company.find_by(schema_name: schema_name)

    # If no company matches the derived schema, return 404
    return tenant_not_found unless company

    # Switch to tenant schema and continue request lifecycle
    Apartment::Tenant.switch(company.schema_name) do
      @app.call(env)
    end
  end

  private

  def public_path?(path)
    PUBLIC_PATHS.any? { |p| path.start_with?(p) }
  end

  def tenant_not_found
    [
      404,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Tenant not found' }.to_json]
    ]
  end
end