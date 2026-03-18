require 'swagger_helper'

RSpec.describe 'api/v1/expenses', type: :request do
  # Shared expense schema used in multiple responses
  let(:expense_schema) do
    {
      type: :object,
      properties: {
        id: { type: :integer },
        amount: { type: :number },
        description: { type: :string },
        expense_date: { type: :string, format: 'date' },
        status: { type: :string, enum: %w[pending approved rejected reimbursed archived] },
        resolved_at: { type: :string, format: 'date-time', nullable: true },
        user: {
          type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            role: { type: :string }
          }
        },
        category: {
          type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string }
          }
        }
      },
      required: %w[id amount description expense_date status]
    }
  end

  path '/api/v1/expenses' do
    get 'List expenses' do
      tags 'Expenses'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :page,        in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page,    in: :query, type: :integer, required: false, description: 'Items per page (default: 10)'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category'
      parameter name: :status,      in: :query, type: :string,  required: false,
                description: 'Filter by status', enum: %w[pending approved rejected reimbursed archived]
      parameter name: :start_date,  in: :query, type: :string,  required: false, description: 'Filter start date (YYYY-MM-DD)'
      parameter name: :end_date,    in: :query, type: :string,  required: false, description: 'Filter end date (YYYY-MM-DD)'

      response '200', 'expenses listed' do
        schema type: :object,
               properties: {
                 expenses: {
                   type: :array,
                   items: { type: :object }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end

    post 'Create an expense' do
      tags 'Expenses'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :expense, in: :body, schema: {
        type: :object,
        properties: {
          expense: {
            type: :object,
            properties: {
              amount: { type: :number, example: 150.00 },
              description: { type: :string, example: 'Flight to client meeting' },
              expense_date: { type: :string, format: 'date', example: '2026-03-17' },
              category_id: { type: :integer, example: 1 }
            },
            required: %w[amount description expense_date category_id]
          }
        }
      }

      response '201', 'expense created' do
        let(:expense) do
          {
            expense: {
              amount: 150.00,
              description: 'Flight to client meeting',
              expense_date: '2026-03-17',
              category_id: create(:category).id
            }
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:expense) { { expense: { amount: nil, description: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/expenses/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get an expense' do
      tags 'Expenses'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'expense found' do
        let(:id) { create(:expense).id }
        run_test!
      end

      response '404', 'expense not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update an expense' do
      tags 'Expenses'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :expense_params, in: :body, schema: {
        type: :object,
        properties: {
          expense: {
            type: :object,
            properties: {
              amount: { type: :number, example: 200.00 },
              description: { type: :string, example: 'Updated description' },
              expense_date: { type: :string, format: 'date' },
              category_id: { type: :integer }
            }
          }
        }
      }

      response '200', 'expense updated' do
        let(:id) { create(:expense).id }
        let(:expense_params) { { expense: { amount: 200.00, description: 'Updated' } } }
        run_test!
      end
    end

    delete 'Delete an expense' do
      tags 'Expenses'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '204', 'expense deleted' do
        let(:id) { create(:expense).id }
        run_test!
      end
    end
  end

  # Workflow actions
  path '/api/v1/expenses/{id}/approve' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Approve an expense' do
      tags 'Expense Workflow'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]
      description 'Admin only. Transitions expense from pending → approved.'

      response '200', 'expense approved' do
        let(:id) { create(:expense).id }
        run_test!
      end

      response '403', 'forbidden - admin only' do
        run_test!
      end

      response '422', 'invalid state transition' do
        let(:id) { create(:expense, :archived).id }
        run_test!
      end
    end
  end

  path '/api/v1/expenses/{id}/reject' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Reject an expense' do
      tags 'Expense Workflow'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]
      description 'Admin only. Transitions expense from pending → rejected.'

      parameter name: :reject_params, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string, example: 'Missing receipt' }
        }
      }

      response '200', 'expense rejected' do
        let(:id) { create(:expense).id }
        let(:reject_params) { { reason: 'Missing receipt' } }
        run_test!
      end

      response '403', 'forbidden - admin only' do
        run_test!
      end
    end
  end

  path '/api/v1/expenses/{id}/reimburse' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Reimburse an expense' do
      tags 'Expense Workflow'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]
      description 'Admin only. Transitions expense from approved → reimbursed.'

      response '200', 'expense reimbursed' do
        let(:id) { create(:expense, :approved).id }
        run_test!
      end

      response '403', 'forbidden - admin only' do
        run_test!
      end
    end
  end

  path '/api/v1/expenses/{id}/archive' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Archive an expense' do
      tags 'Expense Workflow'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]
      description 'Admin only. Archives a reimbursed expense.'

      response '200', 'expense archived' do
        let(:id) { create(:expense, :reimbursed).id }
        run_test!
      end

      response '403', 'forbidden - admin only' do
        run_test!
      end
    end
  end

  # Receipt sub-actions
  path '/api/v1/expenses/{id}/receipts' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'List receipts for an expense' do
      tags 'Receipts'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'receipts listed' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       amount: { type: :number },
                       receipt_date: { type: :string, format: 'date' },
                       notes: { type: :string, nullable: true },
                       status: { type: :string },
                       processed_at: { type: :string, format: 'date-time', nullable: true },
                       file_url: { type: :string, nullable: true }
                     }
                   }
                 }
               }

        let(:id) { create(:expense).id }
        run_test!
      end
    end

    post 'Upload a receipt for an expense' do
      tags 'Receipts'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :receipt, in: :formData, schema: {
        type: :object,
        properties: {
          'receipt[file]': { type: :string, format: :binary, description: 'Receipt file (image or PDF)' },
          'receipt[amount]': { type: :number, example: 150.00 },
          'receipt[receipt_date]': { type: :string, format: 'date', example: '2026-03-17' },
          'receipt[notes]': { type: :string, example: 'Hotel receipt' }
        },
        required: ['receipt[file]', 'receipt[amount]', 'receipt[receipt_date]']
      }

      response '201', 'receipt uploaded' do
        let(:id) { create(:expense).id }
        run_test!
      end
    end
  end

  path '/api/v1/expenses/{id}/receipts/{receipt_id}' do
    parameter name: :id,         in: :path, type: :integer, required: true
    parameter name: :receipt_id, in: :path, type: :integer, required: true

    delete 'Delete a receipt' do
      tags 'Receipts'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '204', 'receipt deleted' do
        let(:expense) { create(:expense) }
        let(:id) { expense.id }
        let(:receipt_id) { create(:receipt, expense: expense).id }
        run_test!
      end

      response '404', 'receipt not found' do
        let(:id) { create(:expense).id }
        let(:receipt_id) { 0 }
        run_test!
      end
    end
  end
end
