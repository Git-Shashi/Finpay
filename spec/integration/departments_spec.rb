require 'swagger_helper'

RSpec.describe 'api/v1/departments', type: :request do
  path '/api/v1/departments' do
    get 'List all departments' do
      tags 'Departments'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [] }]

      response '200', 'departments listed' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:   { type: :integer },
                       name: { type: :string }
                     },
                     required: %w[id name]
                   }
                 }
               }

        run_test!
      end
    end

    post 'Create a department' do
      tags 'Departments'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [] }]

      parameter name: :department, in: :body, schema: {
        type: :object,
        properties: {
          department: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Engineering' }
            },
            required: ['name']
          }
        }
      }

      response '201', 'department created' do
        let(:department) { { department: { name: 'Engineering' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:department) { { department: { name: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/departments/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get a department' do
      tags 'Departments'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [] }]

      response '200', 'department found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id:   { type: :integer },
                     name: { type: :string }
                   },
                   required: %w[id name]
                 }
               }

        let(:id) { create(:department).id }
        run_test!
      end

      response '404', 'department not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update a department' do
      tags 'Departments'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [] }]

      parameter name: :department_params, in: :body, schema: {
        type: :object,
        properties: {
          department: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Name' }
            },
            required: ['name']
          }
        }
      }

      response '200', 'department updated' do
        let(:id) { create(:department).id }
        let(:department_params) { { department: { name: 'Updated Name' } } }
        run_test!
      end
    end

    delete 'Delete a department' do
      tags 'Departments'
      security [{ token_auth: [], client_auth: [], uid_auth: [] }]

      response '204', 'department deleted' do
        let(:id) { create(:department).id }
        run_test!
      end
    end
  end
end
