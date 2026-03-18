require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Finpay API',
        version: 'v1',
        description: 'API documentation for Finpay expense management system'
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Development' }
      ],
      components: {
        securitySchemes: {
          token_auth: {
            type: :apiKey,
            in: :header,
            name: 'access-token',
            description: 'devise_token_auth access token'
          },
          client_auth: {
            type: :apiKey,
            in: :header,
            name: 'client'
          },
          uid_auth: {
            type: :apiKey,
            in: :header,
            name: 'uid'
          }
        }
      },
      security: [
        { token_auth: [], client_auth: [], uid_auth: [] }
      ]
    }
  }

  config.swagger_format = :yaml
end
