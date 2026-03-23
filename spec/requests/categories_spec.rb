require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:admin) do
    Apartment::Tenant.switch('company_beta') { create(:user, :admin) }
  end

  let(:user) do
    Apartment::Tenant.switch('company_beta') { create(:user) }
  end

  let(:admin_headers) do
    Apartment::Tenant.switch('company_beta') { admin.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  end

  let(:auth_headers) do
    Apartment::Tenant.switch('company_beta') { user.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  end

  let(:category) do
    Apartment::Tenant.switch('company_beta') { create(:category) }
  end

  describe 'GET /categories' do
    it 'returns all categories' do
      category
      get '/api/v1/categories', headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /categories/:id' do
    it 'returns the category' do
      get "/api/v1/categories/#{category.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /categories' do
    it 'creates a new category' do
      post '/api/v1/categories',
           params: { category: { name: 'Travel' } },
           headers: admin_headers
      expect(response).to have_http_status(:created)
    end

    it 'returns 403 for non-admin user' do
      post '/api/v1/categories',
           params: { category: { name: 'Travel' } },
           headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH /categories/:id' do
    it 'updates the category' do
      patch "/api/v1/categories/#{category.id}",
            params: { category: { name: 'Updated Category' } },
            headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 403 for non-admin user' do
      patch "/api/v1/categories/#{category.id}",
            params: { category: { name: 'Updated Category' } },
            headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /categories/:id' do
    it 'deletes the category' do
      delete "/api/v1/categories/#{category.id}", headers: admin_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 403 for non-admin user' do
      delete "/api/v1/categories/#{category.id}", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
