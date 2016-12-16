Rails.application.routes.draw do
  root "sessions#new"
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  resources :trigonometries
  resources :histories
  resources :rules, only: [:index, :new, :create, :edit, :update, :destroy]
end
