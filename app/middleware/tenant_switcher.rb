class TenantSwitcher
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    company_id = request.headers['X-Company-Id']

    if company_id.present?
      company = Company.find(company_id)

      Apartment::Tenant.switch(company.schema_name) do
        @app.call(env)
      end
    else
      @app.call(env)
    end
  end
end