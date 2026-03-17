require 'rails_helper'

RSpec.describe Api::V1::DepartmentsController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }
  let(:headers) { { 'X-Company-Id' => 'beta' } }

  let(:department) do
    Apartment::Tenant.switch('company_beta') do
      create(:department)
    end
  end

  describe 'GET /departments' do
    it 'returns all departments' do
      department
      get '/api/v1/departments', headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /departments/:id' do
    it 'returns the department' do
      get "/api/v1/departments/#{department.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /departments' do
    it 'creates a new department' do
      post '/api/v1/departments',
           params: { department: { name: 'Engineering' } },
           headers: headers
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /departments/:id' do
    it 'updates the department' do
      patch "/api/v1/departments/#{department.id}",
            params: { department: { name: 'Updated Dept' } },
            headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /departments/:id' do
    it 'deletes the department' do
      delete "/api/v1/departments/#{department.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end
  end
end
