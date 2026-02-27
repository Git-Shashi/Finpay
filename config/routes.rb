Rails.application.routes.draw do
  # Devise Token Auth (ONLY authentication system)
  mount_devise_token_auth_for 'User', at: 'auth'

  # Public routes
  resources :companies

  # Protected routes (use authenticate_user!)
  resources :departments
  resources :categories
  resources :users
  resources :expenses
end
