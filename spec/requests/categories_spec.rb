require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }
  let(:headers) { { 'X-Company-Id' => 'beta' } }

  let(:category) do
    Apartment::Tenant.switch('company_beta') do
      create(:category)
    end
  end

  describe 'GET /categories' do
    it 'returns all categories' do
      category
      get '/api/v1/categories', headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /categories/:id' do
    it 'returns the category' do
      get "/api/v1/categories/#{category.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /categories' do
    it 'creates a new category' do
      post '/api/v1/categories',
           params: { category: { name: 'Travel' } },
           headers: headers
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /categories/:id' do
    it 'updates the category' do
      patch "/api/v1/categories/#{category.id}",
            params: { category: { name: 'Updated Category' } },
            headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /categories/:id' do
    it 'deletes the category' do
      delete "/api/v1/categories/#{category.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end
  end
end
