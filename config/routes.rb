require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get '/', to: 'static_pages#index'

  resources :events
  resources :bank_accounts, only: [ :new, :create, :show ]
  resources :transactions, only: [ :show, :edit, :update ]
end
