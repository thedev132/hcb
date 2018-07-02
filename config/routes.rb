require 'sidekiq/web'

Rails.application.routes.draw do
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

  resources :g_suite_applications, except: [ :new, :create, :edit, :update ] do
    post 'accept'
    post 'reject'
  end

  resources :g_suite_accounts, only: [ :index ]
  resources :g_suites, except: [ :new, :create, :edit, :update ]
  get 'g_suite', to: 'g_suites#status', as: :g_suite_status

  resources :events do
    resources :organizer_position_invites,
      only: [ :new, :create ],
      path: 'invites'
    resources :g_suites, only: [ :new, :create, :edit, :update ]
    resources :g_suite_applications, only: [ :new, :create, :edit, :update ]
  end

  resources :g_suite_accounts, only: [ :index ], path: 'g_suite_accounts' do
    get 'verify', to: 'g_suite_account#verify'
  end

  resources :sponsors do
    resources :invoices, only: [ :new, :create ]
  end
  resources :invoices, only: [ :show ]

  resources :bank_accounts, only: [ :new, :create, :show ]
  resources :transactions, only: [ :show, :edit, :update ]
end
