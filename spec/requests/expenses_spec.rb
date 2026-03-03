require 'rails_helper'

RSpec.describe ExpensesController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:expense) { create(:expense, user: user, category: category) }
  let(:auth_headers) { user.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  let(:no_auth_headers) { { 'X-Company-Id' => 'beta' } }

  describe 'GET /expenses' do
    it 'returns all expenses' do
      expense
      get '/expenses', headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      get '/expenses', headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /expenses/:id' do
    it 'returns the expense' do
      get "/expenses/#{expense.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      get "/expenses/#{expense.id}", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /expenses' do
    let(:valid_params) do
      {
        expense: {
          category_id: category.id,
          amount: 100.0,
          description: 'Test expense',
          expense_date: Date.today
        }
      }
    end

    it 'creates a new expense' do
      post '/expenses', params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'returns unauthorized without token' do
      post '/expenses', params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error with invalid params' do
      post '/expenses', params: { expense: { amount: nil } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /expenses/:id' do
    let(:valid_params) { { expense: { amount: 200.0 } } }

    it 'updates the expense' do
      patch "/expenses/#{expense.id}", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      patch "/expenses/#{expense.id}", params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /expenses/:id' do
    it 'deletes the expense' do
      delete "/expenses/#{expense.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized without token' do
      delete "/expenses/#{expense.id}", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end