require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root to: 'static_pages#index'

  resources :users, only: [ :edit, :update ] do
    collection do
      get 'auth', to: 'users#auth'
      post 'login_code', to: 'users#login_code'
      post 'exchange_login_code', to: 'users#exchange_login_code'
      delete 'logout', to: 'users#logout'
    end
  end

  resources :organizer_position_invites, only: [ :show ], path: 'invites' do
    post 'accept'
    post 'reject'
  end

  resources :events do
    resources :organizer_position_invites,
      only: [ :new, :create ],
      path: 'invites'
  end

  resources :sponsors do
    resources :invoices, only: [ :new, :create ]
  end
  resources :invoices, only: [ :show ]

  resources :bank_accounts, only: [ :new, :create, :show ]
  resources :transactions, only: [ :index, :show, :edit, :update ]

  resources :cards do
    resources :load_card_requests, except: [ :index ], path: 'load_requests' do
      post 'accept'
    end
  end
  resources :card_requests, path: 'card_requests' do
    post 'reject'
  end
  resources :load_card_requests, only: [ :index ]
end
