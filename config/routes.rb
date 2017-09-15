Rails.application.routes.draw do

  resources :imports, only: [:index] do
    collection do
      get 'load'
      get 'load_all'
      get 'importation_running'
    end
  end

  resources :operators, only: [:index] do
    collection do
      get 'all'
      get 'positive_balances'
      get 'export_positive_balances'
      get 'export_transfers_average'
    end
  end

  resources :operator_informations, only: [:update, :new, :create]

  resources :reserves, only: [:show]

  resources :service_registers, only: [] do
    collection do
      get 'preselect_services'
      get 'credits'
      get 'by_file_number_form'
      post 'export_excel'
      post 'add_services'
      post 'remove_services'
      post 'coming_entries'
      post 'possible_payments'
      post 'payable'
      post 'by_file_number'
    end
  end

  match 'service_registers' => 'service_registers#index',
    via: [:get, :post]

  resources :services, only: [:update, :edit] do
    patch 'update_service', on: :member
  end

  resources :payment_groups, only: [:index, :destroy] do
    member do
      get 'export_to_excel'
      get 'report'
      get 'payment_report_form'
      get 'apply_adjustment_form'
      put 'change_currency'
      put 'change_to_refund'
      put 'remove_incompatible_services'
      post 'send_payment_report'
      post 'draft'
      post 'apply_adjustment'
      post 'update_locators'
    end
  end

  resources :international_payment_groups, controller: 'international_payment_groups',type: 'InternationalPaymentGroup', only: [:show, :destroy] do
    member do
      get 'show_credit'
      get 'bank_charges_form'
      put 'processed'
      put 'sent'
      put 'finished'
      put 'process_credit'
      put 'transfer'
      put 'load_bank_charges'
      post 'draft'
    end
    get 'closed_without_bank_charges', on: :collection
  end

  resources :national_payment_groups, controller: 'national_payment_groups', type: 'NationalPaymentGroup', only: [:show, :destroy] do
    member do
      get 'ig_retention'
      get 'show_credit'
      put 'sent'
      put 'finished'
      put 'process_credit'
      put 'transfer'
      post 'draft'
    end
  end

  resources :refund_payment_groups, controller: 'refund_payment_groups', type: 'RefundPaymentGroup', only: [:show, :destroy] do
    member do
      put 'processed'
      put 'finished'
      post 'draft'
    end
  end

  resources :payment_group_reports, only: [:show, :update] do
    post 'export', on: :member
  end

  resources :statistics, only: [:index] do
    collection do
      get 'export'
      get 'export_excel'
      get 'report_form'
      post 'send_report'
    end
  end

  resources :fund_flow, only: [:index] do
    get 'operator', on: :collection
  end

  resources :agency_payments, only: [:index]

  resources :settings, only: [:index, :update] do
    collection do
      get 'edit_emails'
      put 'update_emails'
    end
  end

  resources :accounts, only: [:update, :destroy, :create]

  namespace :admin do
    get 'index' => 'main#index'
    resources :profiles
  end
  get 'change_profile_operator_category' => 'admin/profiles#change_profile_operator_category'

  get 'no_role' => 'application#no_role'
  get 'forbidden' => 'application#forbidden'
  get 'logout' => 'application#logout'

  root 'application#home'

end
