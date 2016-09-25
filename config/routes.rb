Rails.application.routes.draw do
  root to: 'home#index'

  resources :users, except: [:index, :destroy]
  resource :session, only: [:new, :create, :destroy]
end
