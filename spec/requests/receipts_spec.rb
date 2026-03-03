require 'rails_helper'

RSpec.describe ReceiptsController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:user) do
    Apartment::Tenant.switch('company_beta') do
      create(:user)
    end
  end

  let(:auth_headers) do
    Apartment::Tenant.switch('company_beta') do
      user.create_new_auth_token.merge('X-Company-Id' => 'beta')
    end
  end

  let(:no_auth_headers) { { 'X-Company-Id' => 'beta' } }

  let(:category) do
    Apartment::Tenant.switch('company_beta') do
      create(:category)
    end
  end

  let(:expense) do
    Apartment::Tenant.switch('company_beta') do
      create(:expense, user: user, category: category)
    end
  end

  let(:receipt) do
    Apartment::Tenant.switch('company_beta') do
      create(:receipt, expense: expense)
    end
  end

  describe 'GET /receipts' do
    it 'returns all receipts' do
      receipt
      get '/receipts', headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      get '/receipts', headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /receipts' do
    let(:valid_params) do
      {
        expense_id: expense.id,
        receipt: {
          file_url: 'http://example.com/receipt.pdf',
          file_name: 'receipt.pdf',
          file_type: 'pdf',
          amount: 50.0,
          receipt_date: Date.today
        }
      }
    end

    it 'creates a new receipt' do
      post '/receipts', params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'returns unauthorized without token' do
      post '/receipts', params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /receipts/:id' do
    it 'deletes the receipt' do
      delete "/receipts/#{receipt.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized without token' do
      delete "/receipts/#{receipt.id}", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end