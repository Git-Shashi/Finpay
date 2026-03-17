require 'rails_helper'

RSpec.describe Api::V1::ExpensesController, type: :request do
  let!(:company) { Company.find_by(subdomain: 'beta') || create(:company) }

  let(:user) do
    Apartment::Tenant.switch('company_beta') { create(:user) }
  end

  let(:admin) do
    Apartment::Tenant.switch('company_beta') { create(:user, :admin) }
  end

  let(:category) do
    Apartment::Tenant.switch('company_beta') { create(:category) }
  end

  let(:expense) do
    Apartment::Tenant.switch('company_beta') { create(:expense, user: user, category: category) }
  end

  let(:auth_headers) do
    Apartment::Tenant.switch('company_beta') { user.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  end

  let(:admin_headers) do
    Apartment::Tenant.switch('company_beta') { admin.create_new_auth_token.merge('X-Company-Id' => 'beta') }
  end

  let(:no_auth_headers) { { 'X-Company-Id' => 'beta' } }

  before do
    allow(AuditLogWorker).to receive(:perform_async)
    allow(ReceiptProcessorWorker).to receive(:perform_async)
  end

  describe 'GET /expenses' do
    it 'returns all expenses' do
      expense
      get '/api/v1/expenses', headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns expenses array and pagination meta' do
      expense
      get '/api/v1/expenses', headers: auth_headers
      json = response.parsed_body
      expect(json).to have_key('expenses')
      expect(json).to have_key('pagination')
      expect(json['expenses']).to be_an(Array)
    end

    it 'filters by category_id' do
      expense
      get '/api/v1/expenses', params: { category_id: category.id }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'filters by status' do
      expense
      get '/api/v1/expenses', params: { status: 'pending' }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'filters by date range' do
      expense
      get '/api/v1/expenses', params: { start_date: 30.days.ago.to_date, end_date: Time.zone.today }, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      get '/api/v1/expenses', headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /expenses/:id' do
    it 'returns the expense' do
      get "/api/v1/expenses/#{expense.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for unknown expense' do
      get '/api/v1/expenses/0', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unauthorized without token' do
      get "/api/v1/expenses/#{expense.id}", headers: no_auth_headers
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
          expense_date: Time.zone.today
        }
      }
    end

    it 'creates a new expense' do
      post '/api/v1/expenses', params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'enqueues AuditLogWorker on create' do
      post '/api/v1/expenses', params: valid_params, headers: auth_headers
      expect(AuditLogWorker).to have_received(:perform_async)
    end

    it 'returns unauthorized without token' do
      post '/api/v1/expenses', params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unprocessable_entity with invalid params' do
      post '/api/v1/expenses', params: { expense: { amount: nil } }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request when expense key is missing' do
      post '/api/v1/expenses', params: {}, headers: auth_headers
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PATCH /expenses/:id' do
    let(:valid_params) { { expense: { amount: 200.0 } } }

    it 'updates the expense' do
      patch "/api/v1/expenses/#{expense.id}", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for unknown expense' do
      patch '/api/v1/expenses/0', params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unauthorized without token' do
      patch "/api/v1/expenses/#{expense.id}", params: valid_params, headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /expenses/:id' do
    it 'deletes the expense' do
      delete "/api/v1/expenses/#{expense.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for unknown expense' do
      delete '/api/v1/expenses/0', headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unauthorized without token' do
      delete "/api/v1/expenses/#{expense.id}", headers: no_auth_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /expenses/:id/approve' do
    it 'approves the expense as admin' do
      post "/api/v1/expenses/#{expense.id}/approve", headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns forbidden for non-admin' do
      post "/api/v1/expenses/#{expense.id}/approve", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns error when transition is invalid' do
      approved = Apartment::Tenant.switch('company_beta') { create(:expense, :approved, user: user, category: category) }
      post "/api/v1/expenses/#{approved.id}/approve", headers: admin_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /expenses/:id/reject' do
    it 'rejects the expense as admin' do
      post "/api/v1/expenses/#{expense.id}/reject", headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns forbidden for non-admin' do
      post "/api/v1/expenses/#{expense.id}/reject", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'accepts a reason param' do
      post "/api/v1/expenses/#{expense.id}/reject", params: { reason: 'over budget' }, headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns error when transition is invalid' do
      rejected = Apartment::Tenant.switch('company_beta') { create(:expense, :rejected, user: user, category: category) }
      post "/api/v1/expenses/#{rejected.id}/reject", headers: admin_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /expenses/:id/reimburse' do
    let(:approved_expense) do
      Apartment::Tenant.switch('company_beta') { create(:expense, :approved, user: user, category: category) }
    end

    it 'reimburses the expense as admin' do
      post "/api/v1/expenses/#{approved_expense.id}/reimburse", headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns forbidden for non-admin' do
      post "/api/v1/expenses/#{approved_expense.id}/reimburse", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns error when transition is invalid (pending expense)' do
      post "/api/v1/expenses/#{expense.id}/reimburse", headers: admin_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /expenses/:id/archive' do
    it 'archives the expense as admin' do
      post "/api/v1/expenses/#{expense.id}/archive", headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns forbidden for non-admin' do
      post "/api/v1/expenses/#{expense.id}/archive", headers: auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns error when already archived' do
      archived = Apartment::Tenant.switch('company_beta') { create(:expense, :archived, user: user, category: category) }
      post "/api/v1/expenses/#{archived.id}/archive", headers: admin_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /expenses/:id/receipts' do
    it 'returns receipts for the expense' do
      get "/api/v1/expenses/#{expense.id}/receipts", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 if expense does not belong to current user' do
      other_expense = Apartment::Tenant.switch('company_beta') { create(:expense) }
      get "/api/v1/expenses/#{other_expense.id}/receipts", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /expenses/:id/receipts' do
    let(:file) { fixture_file_upload('test.pdf', 'application/pdf') }

    it 'attaches a receipt to the expense' do
      post "/api/v1/expenses/#{expense.id}/receipts",
           params: { receipt: { file: file, amount: 50.0, receipt_date: Time.zone.today, notes: 'cab' } },
           headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'enqueues ReceiptProcessorWorker' do
      post "/api/v1/expenses/#{expense.id}/receipts",
           params: { receipt: { file: file, amount: 50.0, receipt_date: Time.zone.today, notes: 'cab' } },
           headers: auth_headers
      expect(ReceiptProcessorWorker).to have_received(:perform_async)
    end
  end

  describe 'DELETE /expenses/:id/receipts/:receipt_id' do
    let(:receipt) do
      Apartment::Tenant.switch('company_beta') { create(:receipt, expense: expense) }
    end

    it 'deletes the receipt' do
      delete "/api/v1/expenses/#{expense.id}/receipts/#{receipt.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for unknown receipt' do
      delete "/api/v1/expenses/#{expense.id}/receipts/0", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
