require 'rails_helper'

RSpec.describe CategoriesController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:auth_headers) { user.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  let(:no_auth_headers) { { 'X-Company-Id' => 'beta' } }

  describe 'GET /categories' do
    it 'returns all categories' do
      category
      get '/categories', headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /categories' do
    it 'creates a new category' do
      post '/categories',
           params: { category: { name: 'Travel' } },
           headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'returns error with invalid params' do
      post '/categories',
           params: { category: { name: nil } },
           headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end