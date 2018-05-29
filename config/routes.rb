Rails.application.routes.draw do
  resources :events
  resources :bank_accounts, only: [ :new, :create, :show ]
  resources :transactions, only: [ :show ]
end
