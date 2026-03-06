class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show update destroy]

  # GET /companies
  def index
    companies = Company.all
    render json: CompanySerializer.new(companies).serialize, status: :ok
  end

  # GET /companies/:id
  def show
    render json: CompanySerializer.new(@company).serialize, status: :ok
  end

  # POST /companies
  def create
    company = Company.new(company_params)

    if company.save
      Tenants::ProvisioningService.new(company).call
      render json: CompanySerializer.new(company).serialize, status: :created
    else
      render json: { errors: company.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:id
  def update
    if @company.update(company_params)
      render json: CompanySerializer.new(@company).serialize, status: :ok
    else
      render json: { errors: @company.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /companies/:id
  def destroy
    Apartment::Tenant.drop(@company.schema_name) if @company.schema_name.present?
    @company.destroy

    render json: { message: 'Company deleted successfully' }, status: :ok
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found' }, status: :not_found
  end

  def company_params
    params.require(:company).permit(:name, :subdomain)
  end
end
