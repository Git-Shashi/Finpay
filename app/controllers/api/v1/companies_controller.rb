class CompaniesController < ApplicationController
  def index
    render_success CompanySerializer.new(Company.all).serialize
  end

  def show
    render_success CompanySerializer.new(company).serialize
  end

  def create
    company = Company.new(company_params)
    company.save!
    Tenants::ProvisioningService.call(company)
    render_created CompanySerializer.new(company).serialize
  end

  def update
    company.update!(company_params)
    render_success CompanySerializer.new(company).serialize
  end

  def destroy
    Apartment::Tenant.drop(company.schema_name) if company.schema_name.present?
    company.destroy
    render_message I18n.t("companies.deleted")
  end

  private

  def company
    @company ||= Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :subdomain)
  end
end
