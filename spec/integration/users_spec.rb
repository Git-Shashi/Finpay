require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'List all users' do
      tags 'Users'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'users listed' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       email: { type: :string },
                       role: { type: :string, enum: %w[employee manager admin] }
                     },
                     required: %w[id name email role]
                   }
                 }
               }

        run_test!
      end
    end

    post 'Create a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' },
              password: { type: :string, example: 'secret123' },
              password_confirmation: { type: :string, example: 'secret123' },
              department_id: { type: :integer, example: 1 }
            },
            required: %w[name email password password_confirmation]
          }
        }
      }

      response '201', 'user created' do
        let(:department) { create(:department) }
        let(:user) do
          {
            user: {
              name: 'Jane Doe',
              email: 'jane@example.com',
              password: 'secret123',
              password_confirmation: 'secret123',
              department_id: department.id
            }
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { user: { name: '', email: 'not-an-email' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get a user' do
      tags 'Users'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '200', 'user found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     email: { type: :string },
                     role: { type: :string }
                   },
                   required: %w[id name email role]
                 }
               }

        let(:id) { create(:user).id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated Name' },
              email: { type: :string, example: 'updated@example.com' },
              department_id: { type: :integer, example: 1 }
            }
          }
        }
      }

      response '200', 'user updated' do
        let(:id) { create(:user).id }
        let(:user_params) { { user: { name: 'Updated Name' } } }
        run_test!
      end
    end

    delete 'Delete a user' do
      tags 'Users'
      security [{ token_auth: [], client_auth: [], uid_auth: [], company_id: [] }]

      response '204', 'user deleted' do
        let(:id) { create(:user).id }
        run_test!
      end
    end
  end
end
