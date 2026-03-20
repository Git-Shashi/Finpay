require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }
  let(:headers) { { 'X-Company-Id' => 'beta' } }

  let(:department) do
    Apartment::Tenant.switch('company_beta') { create(:department) }
  end

  let(:user) do
    Apartment::Tenant.switch('company_beta') { create(:user) }
  end

  describe 'GET /users' do
    it 'returns all users' do
      user
      get '/api/v1/users', headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /users/:id' do
    it 'returns the user' do
      get "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /users' do
    it 'creates a new user' do
      post '/api/v1/users',
           params: {
             user: {
               name: 'New User',
               email: 'newuser@example.com',
               password: 'password',
               password_confirmation: 'password',
               department_id: department.id
             }
           },
           headers: headers
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /users/:id' do
    it 'updates the user' do
      patch "/api/v1/users/#{user.id}",
            params: { user: { name: 'Updated Name' } },
            headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /users/:id' do
    it 'deletes the user' do
      delete "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end
  end
end
