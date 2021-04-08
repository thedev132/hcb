require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new
  mount Blazer::Engine, at: "blazer", constraints: AdminConstraint.new
  get '/sidekiq', to: 'users#auth' # fallback if adminconstraint fails, meaning user is not signed in
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root to: 'static_pages#index'
  get 'stats', to: 'static_pages#stats'
  get 'project_stats', to: 'static_pages#project_stats'
  get 'bookkeeping', to: 'admin#bookkeeping'
  get 'stripe_charge_lookup', to: 'static_pages#stripe_charge_lookup'

  scope :my do
    get '/', to: redirect('/'), as: :my
    get 'settings', to: 'users#edit', as: :my_settings

    resources :stripe_authorizations, only: [:index, :show], path: 'transactions' do
      resources :comments
    end
    get 'inbox', to: 'static_pages#my_inbox', as: :my_inbox
    get 'stripe_authorizations_list', to: 'static_pages#my_stripe_authorizations_list', as: :my_stripe_authorizations_list
    get 'receipts', to: redirect('/my/inbox')
    get 'receipts/:id', to: 'stripe_authorizations#receipt', as: :my_receipt

    get 'cards', to: 'static_pages#my_cards', as: :my_cards
    get 'cards/shipping', to: 'stripe_cards#shipping', as: :my_cards_shipping
  end
  post 'receipts/upload', to: 'receipts#upload'
  delete 'receipts/destroy', to: 'receipts#destroy'

  post 'receiptable/:receiptable_type/:receiptable_id/mark_no_or_lost', to: 'receiptables#mark_no_or_lost', as: :receiptable_mark_no_or_lost

  resources :reports, only: [] do
    member do
      get 'fees', to: 'reports#fees'
    end
  end

  resources :users, only: [:edit, :update] do
    collection do
      get 'impersonate', to: 'users#impersonate'
      get 'auth', to: 'users#auth'
      post 'login_code', to: 'users#login_code'
      post 'exchange_login_code', to: 'users#exchange_login_code'
      delete 'logout', to: 'users#logout'

      # sometimes users refresh the login code page and get 404'd
      get 'exchange_login_code', to: redirect('/users/auth', status: 301)
      get 'login_code', to: redirect('/users/auth', status: 301)
    end
    post 'delete_profile_picture', to: 'users#delete_profile_picture'
    patch 'stripe_cardholder_profile', to: 'stripe_cardholders#update_profile'
  end

  # webhooks
  post 'webhooks/donations', to: 'donations#accept_donation_hook'

  resources :admin, only: [] do
    collection do
      get 'hcb_codes', to: 'admin#hcb_codes'
      get 'fees', to: 'admin#fees'
      get 'users', to: 'admin#users'
      get 'ledger', to: 'admin#ledger'
      get 'pending_ledger', to: 'admin#pending_ledger'
      get 'ach', to: 'admin#ach'
      get 'check', to: 'admin#check'
      get 'events', to: 'admin#events'
      get 'donations', to: 'admin#donations'
      get 'disbursements', to: 'admin#disbursements'
      get 'disbursement_new', to: 'admin#disbursement_new'
      post 'disbursement_create', to: 'admin#disbursement_create'
      get 'invoices', to: 'admin#invoices'
      get 'sponsors', to: 'admin#sponsors'
      get 'google_workspaces', to: 'admin#google_workspaces'
    end

    member do
      get 'transaction', to: 'admin#transaction'
      get 'event_process', to: 'admin#event_process'
      get 'ach_start_approval', to: 'admin#ach_start_approval'
      post 'ach_approve', to: 'admin#ach_approve'
      post 'ach_reject', to: 'admin#ach_reject'
      get 'check_process', to: 'admin#check_process'
      get 'check_positive_pay_csv', to: 'admin#check_positive_pay_csv'
      post 'check_mark_in_transit_and_processed', to: 'admin#check_mark_in_transit_and_processed'
      get 'google_workspace_process', to: 'admin#google_workspace_process'
      post 'google_workspace_update', to: 'admin#google_workspace_update'
      get 'invoice_process', to: 'admin#invoice_process'
      post 'invoice_mark_paid', to: 'admin#invoice_mark_paid'
    end
  end

  post 'set_event/:id', to: 'admin#set_event', as: :set_event
  get 'transactions/dedupe', to: 'admin#transaction_dedupe', as: :transaction_dedupe

  resources :organizer_position_invites, only: [:index, :show], path: 'invites' do
    post 'accept'
    post 'reject'
    post 'cancel'
  end

  resources :organizer_positions, only: [:destroy], as: 'organizers' do
    resources :organizer_position_deletion_requests, only: [:new], as: 'remove'
  end

  resources :organizer_position_deletion_requests, only: [:index, :show, :create] do
    post 'close'
    post 'open'

    resources :comments
  end

  resources :g_suite_accounts, only: [:index, :create, :update, :edit, :destroy], path: 'g_suite_accounts' do
    put 'reset_password'
    put 'toggle_suspension'
    get 'verify', to: 'g_suite_account#verify'
    post 'reject'
  end

  resources :g_suites, except: [:new, :create, :edit, :update] do
    resources :g_suite_accounts, only: [:create]

    resources :comments
  end

  resources :sponsors

  resources :invoices, only: [:show] do
    collection do
      get '', to: 'invoices#all_index', as: :all
    end
    get 'manual_payment'
    post 'manually_mark_as_paid'
    post 'archive'
    post 'unarchive'
    resources :comments
  end

  resources :stripe_authorizations, only: [:show, :index] do
    resources :comments
  end
  resources :stripe_cardholders, only: [:new, :create, :update]
  resources :stripe_cards, only: %i[create index show] do
    post 'freeze'
    post 'defrost'
  end
  resources :emburse_cards, except: %i[new create]

  resources :checks, only: [:show] do
    get 'view_scan'
    post 'cancel'
    get 'positive_pay_csv'

    get 'start_void'
    post 'void'
    get 'refund', to: 'checks#refund_get'
    post 'refund', to: 'checks#refund'

    resources :comments
  end

  resources :ach_transfers, only: [:show] do
    resources :comments
  end

  resources :ach_transfers do
    get 'confirmation', to: 'ach_transfers#transfer_confirmation_letter'
  end

  resources :disbursements, only: [:index, :new, :create, :show, :edit, :update] do
    post 'mark_fulfilled'
    post 'reject'
  end

  resources :comments, only: [:edit, :update]

  resources :documents, except: [:index] do
    collection do
      get '', to: 'documents#common_index', as: :common
    end
    get 'download'
  end

  resources :bank_accounts, only: [:new, :create, :update, :show, :index] do
    get 'reauthenticate'
  end

  resources :hcb_codes, path: '/hcb', only: [:show] do
    member do
      post 'comment'
      post 'receipt'
      get 'attach_receipt'
    end
  end
  
  resources :canonical_pending_transactions, only: [:show] do
  end

  resources :canonical_transactions, only: [:show, :edit] do
    member do
      post 'waive_fee'
      post 'unwaive_fee'
      post 'mark_bank_fee'
      post 'set_custom_memo'
    end

    resources :comments
  end

  resources :transactions, only: [:index, :show, :edit, :update] do
    collection do
      get 'export'
    end
    resources :comments
  end

  resources :fee_reimbursements, only: [:index, :show, :edit, :update] do
    collection do
      get 'export'
    end
    post 'mark_as_processed'
    post 'mark_as_unprocessed'
    resources :comments
  end

  get 'branding', to: 'static_pages#branding'
  get 'faq', to: 'static_pages#faq'
  
  get 'pending_fees', to: 'admin#pending_fees'
  get 'export_pending_fees', to: 'admin#export_pending_fees'
  get 'pending_disbursements', to: 'admin#pending_disbursements'
  get 'export_pending_disbursements', to: 'admin#export_pending_disbursements'
  get 'audit', to: 'admin#audit'

  resources :central, only: [:index] do
    collection do
      get 'ledger'
    end
  end

  resources :emburse_card_requests, path: 'emburse_card_requests', except: [:new, :create] do
    collection do
      get 'export'
    end
    post 'reject'
    post 'cancel'

    resources :comments
  end

  resources :emburse_transfers, except: [:new, :create] do
    collection do
      get 'export'
    end
    post 'accept'
    post 'reject'
    post 'cancel'
    resources :comments
  end

  resources :emburse_transactions, only: [:index, :edit, :update, :show] do
    resources :comments
  end

  resources :donations, only: [:show] do
    collection do
      get 'start/:event_name', to: 'donations#start_donation', as: 'start_donation'
      post 'start/:event_name', to: 'donations#make_donation', as: 'make_donation'
      get 'qr/:event_name.png', to: 'donations#qr_code', as: 'qr_code'
      get ':event_name/:donation', to: 'donations#finish_donation', as: 'finish_donation'

    end

    member do
      post 'refund', to: 'donations#refund'
    end

    resources :comments
  end

  # api
  get  'api/v1/events/find', to: 'api#event_find'
  post 'api/v1/events', to: 'api#event_new'
  post 'api/v1/disbursements', to: 'api#disbursement_new'

  post 'stripe/webhook', to: 'stripe#webhook'

  post 'export/finances', to: 'exports#financial_export'

  get 'pending_fees', to: 'admin#pending_fees'
  get 'negative_events', to: 'admin#negative_events'

  get 'admin_tasks', to: 'admin#tasks'
  get 'admin_task_size', to: 'admin#task_size'
  get 'admin_search', to: 'admin#search'
  post 'admin_search', to: 'admin#search'

  resources :ops_checkins, only: [:create]

  get '/integrations/frankly' => 'integrations#frankly'

  post '/events' => 'events#create'
  get '/events' => 'events#index'
  get '/event_by_airtable_id/:airtable_id' => 'events#by_airtable_id'
  resources :events, path: '/' do
    get 'fees', to: 'events#fees', as: :fees
    get 'dashboard_stats', to: 'events#dashboard_stats', as: :dashboard_stats
    put 'toggle_hidden', to: 'events#toggle_hidden'

    get 'team', to: 'events#team', as: :team
    get 'google_workspace', to: 'events#g_suite_overview', as: :g_suite_overview
    post 'g_suite_create', to: 'events#g_suite_create', as: :g_suite_create
    put 'g_suite_verify', to: 'events#g_suite_verify', as: :g_suite_verify
    get 'emburse_cards', to: 'events#emburse_card_overview', as: :emburse_cards_overview
    get 'cards', to: 'events#card_overview', as: :cards_overview
    get 'cards/new', to: 'stripe_cards#new'
    get 'stripe_cards/shipping', to: 'stripe_cards#shipping', as: :stripe_cards_shipping

    get 'transfers', to: 'events#transfers', as: :transfers
    get 'promotions', to: 'events#promotions', as: :promotions
    get 'reimbursements', to: 'events#reimbursements', as: :reimbursements
    get 'donations', to: 'events#donation_overview', as: :donation_overview
    # suspend this while check processing is on hold
    resources :checks, only: [:new, :create]
    resources :ach_transfers, only: [:new, :create]
    resources :organizer_position_invites,
              only: [:new, :create],
              path: 'invites'
    resources :g_suites, only: [:new, :create, :edit, :update]
    resources :documents, only: [:index]
    get 'fiscal_sponsorship_letter', to: 'documents#fiscal_sponsorship_letter'
    resources :invoices, only: [:new, :create, :index]
    resources :stripe_authorizations, only: [:show] do
      resources :comments
    end
  end

  # rewrite old event urls to the new ones not prefixed by /events/
  get '/events/*path', to: redirect('/%{path}', status: 302)

  # Beware: Routes after "resources :events" might be overwritten by a
  # similarly named event
end
