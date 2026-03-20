require 'swagger_helper'

RSpec.describe 'api/v1/categories', type: :request do
  include_context 'swagger auth'

  path '/api/v1/categories' do
    get 'List all categories' do
      tags 'Categories'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'categories listed' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   created_at: { type: :string, format: :string },
                   updated_at: { type: :string, format: :string }
                 },
                 required: %w[id name]
               }

        run_test!
      end
    end

    post 'Create a category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Travel' }
            },
            required: ['name']
          }
        }
      }

      response '201', 'category created' do
        let(:category) { { category: { name: 'Travel' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:category) { { category: { name: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get a category' do
      tags 'Categories'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'category found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 created_at: { type: :string, format: :string },
                 updated_at: { type: :string, format: :string }
               },
               required: %w[id name]

        let(:id) { create(:category).id }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update a category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :category_params, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Name' }
            },
            required: ['name']
          }
        }
      }

      response '200', 'category updated' do
        let(:id) { create(:category).id }
        let(:category_params) { { category: { name: 'Updated Name' } } }
        run_test!
      end
    end

    delete 'Delete a category' do
      tags 'Categories'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '204', 'category deleted' do
        let(:id) { create(:category).id }
        run_test!
      end
    end
  end
end
