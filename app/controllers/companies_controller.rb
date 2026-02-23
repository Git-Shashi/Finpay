class CompaniesController < ApplicationController
    def create
    company = Company.create!(
     name: company_params[:name],
      schema_name: "company_#{SecureRandom.hex(4)}"
    )

    Tenants::ProvisioningService.new(company).call

    render json: company, status: :created
  end
  private

def company_params
  params.require(:company).permit(:name)
end
end
