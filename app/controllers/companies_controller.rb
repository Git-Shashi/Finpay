class CompaniesController < ApplicationController
    def create
    company = Company.create!(
      name: params[:name],
      schema_name: "company_#{SecureRandom.hex(4)}"
    )

    Tenants::ProvisioningService.new(company).call

    render json: company, status: :created
  end
end
