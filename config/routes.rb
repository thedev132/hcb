require 'sidekiq/web'

Rails.application.routes.draw do
  resources :g_suites
  mount Sidekiq::Web => '/sidekiq'

  root to: 'static_pages#index'

  resources :users, only: [] do
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
    resources :g_suite_applications, only: [ :show ], path: 'gsuite_invite'
    resources :organizer_position_invites,
      only: [ :new, :create ],
      path: 'invites'
  end

  resources :sponsors do
    resources :invoices, only: [ :new, :create ]
  end
  resources :invoices, only: [ :show ]

  resources :bank_accounts, only: [ :new, :create, :show ]
  resources :transactions, only: [ :show, :edit, :update ]
end
