class CompaniesController < ApplicationController
  # GET /companies
  def index
    companies = Company.all
    render json: CompanySerializer.new(companies).serialize, status: :ok
  end

  # GET /companies/:id
  def show
    if company
      render json: CompanySerializer.new(company).serialize, status: :ok
    else
      render json: { error: 'Company not found' }, status: :not_found
    end
  end

  # POST /companies
  def create
    company = Company.new(company_params)
    if company.save
      Tenants::ProvisioningService.new(company).call
      render json: CompanySerializer.new(company).serialize, status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:id
  def update
    if company
      if company.update(company_params)
        render json: CompanySerializer.new(company).serialize, status: :ok
      else
        render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Company not found' }, status: :not_found
    end
  end

  # DELETE /companies/:id
  def destroy
    if company
      Apartment::Tenant.drop(company.schema_name) if company.schema_name.present?
      company.destroy
      render json: { message: 'Company deleted successfully' }, status: :ok
    else
      render json: { error: 'Company not found' }, status: :not_found
    end
  end

  private

  def company
    @company ||= Company.find_by(id: params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :subdomain)
  end
end
