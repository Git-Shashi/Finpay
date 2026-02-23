class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :update, :destroy]

  # GET /companies
  def index
    companies = Company.all
    render json: companies, status: :ok
  end

  # GET /companies/:id
  def show
    render json: @company, status: :ok
  end

  # POST /companies
  def create
    company = Company.new(company_params)
   # company.schema_name = "company_#{SecureRandom.hex(4)}"

    if company.save
      Tenants::ProvisioningService.new(company).call
      render json: company, status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:id
  def update
    if @company.update(company_params)
      render json: @company, status: :ok
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:id
  def destroy
    # Tenant schema bhi delete karo
    Apartment::Tenant.drop(@company.schema_name) if @company.schema_name.present?
    @company.destroy

    render json: { message: "Company deleted successfully" }, status: :ok
  end

  private
  # Set company for show, update, destroy actions
  # If company not found, return 404 with error message "Company not found"
  # And return from the method to prevent further execution 
  # This ensures that if the company is not found, We don't need to worry about rerendering the response multiple times or executing code that depends on @company being set.
  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Company not found" }, status: :not_found
    return
  end

  def company_params
  params.require(:company).permit(:name, :subdomain)
end
end