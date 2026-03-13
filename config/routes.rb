require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV.fetch('SIDEKIQ_USERNAME', 'admin') &&
    password == ENV.fetch('SIDEKIQ_PASSWORD', 'password')
end

Rails.application.routes.draw do
  # Devise Token Auth (ONLY authentication system)
  mount_devise_token_auth_for 'User', at: 'auth'

  # Public routes
  resources :companies

  # Protected routes (use authenticate_user!)
  resources :departments
  resources :categories
  resources :users
  resources :expenses do
    member do
      post :approve
      post :reject
      post :reimburse
      post :archive

      # Receipt routes handled by ExpensesController
      get  :receipts,       action: :receipts
      post :receipts,       action: :create_receipt
      delete 'receipts/:receipt_id', action: :destroy_receipt
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end
