require 'rails_helper'

RSpec.describe ReceiptsController, type: :request do
 let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:user) { create(:user) }
  let(:expense) { create(:expense, user: user) }
  let(:receipt) { create(:receipt, expense: expense) }
  let(:auth_headers) { user.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  let(:no_auth_headers) { { 'X-Company-Id' => 'beta' } }

  describe 'GET /expenses/:expense_id/receipts' do
    it 'returns all receipts for an expense' do
      receipt
      get "/expenses/#{expense.id}/receipts", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      get "/expenses/#{expense.id}/receipts", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /expenses/:expense_id/receipts' do
    let(:valid_params) do
      {
        receipt: {
          file_url: 'http://example.com/receipt.pdf',
          file_name: 'receipt.pdf',
          file_type: 'pdf',
          amount: 100.0,
          receipt_date: Date.today
        }
      }
    end

    it 'creates a new receipt' do
      post "/expenses/#{expense.id}/receipts", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'returns unauthorized without token' do
      post "/expenses/#{expense.id}/receipts", params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error with invalid params' do
      post "/expenses/#{expense.id}/receipts",
           params: { receipt: { file_url: nil } },
           headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /expenses/:expense_id/receipts/:id' do
    it 'deletes the receipt' do
      delete "/expenses/#{expense.id}/receipts/#{receipt.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized without token' do
      delete "/expenses/#{expense.id}/receipts/#{receipt.id}", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end