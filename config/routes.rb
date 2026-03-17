require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV.fetch('SIDEKIQ_USERNAME', 'admin') &&
    password == ENV.fetch('SIDEKIQ_PASSWORD', 'password')
end

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'

      resources :companies
      resources :departments
      resources :categories
      resources :users
      resources :expenses do
        member do
          post :approve
          post :reject
          post :reimburse
          post :archive
          get    :receipts,              action: :receipts
          post   :receipts,              action: :create_receipt
          delete 'receipts/:receipt_id', action: :destroy_receipt
        end
      end
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end
