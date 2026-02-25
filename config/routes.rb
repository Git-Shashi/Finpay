Rails.application.routes.draw do
  # Mount Devise (no HTML routes)
  devise_for :users,
             skip: [:sessions, :registrations],
             defaults: { format: :json }

  # ---- JWT auth routes (INSIDE devise_scope) ----
  devise_scope :user do
    post   '/login',  to: 'users/sessions#create'
    delete '/logout', to: 'users/sessions#destroy'
  end

  # ---- Public routes ----
  resources :companies

  # ---- Protected routes ----
  resources :departments
  resources :categories
  resources :users
  resources :expenses
end
