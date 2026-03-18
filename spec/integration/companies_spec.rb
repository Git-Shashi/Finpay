require 'swagger_helper'

RSpec.describe 'api/v1/companies', type: :request do
  path '/api/v1/companies' do
    get 'List all companies' do
      tags 'Companies'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'companies listed' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       subdomain: { type: :string }
                     },
                     required: %w[id name subdomain]
                   }
                 }
               }

        run_test!
      end
    end

    post 'Create a company' do
      tags 'Companies'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :company, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Acme Corp' },
              subdomain: { type: :string, example: 'acme' }
            },
            required: %w[name subdomain]
          }
        }
      }

      response '201', 'company created' do
        let(:company) { { company: { name: 'Acme Corp', subdomain: 'acme' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:company) { { company: { name: '', subdomain: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/companies/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get a company' do
      tags 'Companies'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'company found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     subdomain: { type: :string }
                   },
                   required: %w[id name subdomain]
                 }
               }

        let(:id) { create(:company).id }
        run_test!
      end

      response '404', 'company not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update a company' do
      tags 'Companies'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :company_params, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Corp' },
              subdomain: { type: :string, example: 'updated' }
            }
          }
        }
      }

      response '200', 'company updated' do
        let(:id) { create(:company).id }
        let(:company_params) { { company: { name: 'Updated Corp' } } }
        run_test!
      end
    end

    delete 'Delete a company' do
      tags 'Companies'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'company deleted' do
        let(:id) { create(:company).id }
        run_test!
      end

      response '404', 'company not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
