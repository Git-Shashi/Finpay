# spec/requests/companies_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::CompaniesController, type: :request do
  describe 'GET /companies' do
    it 'returns all companies' do
      get '/api/v1/companies'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /companies/:id' do
    let(:company) { Company.first }

    it 'returns the company' do
      get "/api/v1/companies/#{company.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'returns not found for invalid id' do
      get '/api/v1/companies/99999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /companies' do
    let(:valid_params) do
      { company: { name: 'Delta Corp', subdomain: 'delta' } }
    end

    it 'creates a new company' do
      expect do
        post '/api/v1/companies', params: valid_params
      end.to change(Company, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns error with invalid params' do
      post '/api/v1/companies', params: { company: { name: nil, subdomain: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error with duplicate subdomain' do
      post '/api/v1/companies', params: { company: { name: 'Beta Again', subdomain: 'beta' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /companies/:id' do
    let(:company) { Company.first }

    it 'updates the company' do
      patch "/api/v1/companies/#{company.id}", params: { company: { name: 'Updated Corp' } }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['name']).to eq('Updated Corp')
    end

    it 'returns not found for invalid id' do
      patch '/api/v1/companies/99999', params: { company: { name: 'Nope' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /companies/:id' do
    let!(:company) do
      Company.create!(name: 'Temp Corp', subdomain: 'temp', schema_name: 'company_temp')
    end

    before do
      Apartment::Tenant.create(company.schema_name)
    rescue StandardError
      nil
    end

    it 'deletes the company' do
      expect do
        delete "/api/v1/companies/#{company.id}"
      end.to change(Company, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it 'returns not found for invalid id' do
      delete '/api/v1/companies/99999'
      expect(response).to have_http_status(:not_found)
    end
  end
end
