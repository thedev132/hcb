class BankAccountsController < ApplicationController
  before_action :set_link_vars, only: [:new, :reauthenticate]

  def new
    authorize BankAccount
  end

  def create
    public_token = params[:auth][:public_token]
    account_id = params[:auth][:account_id]
    account_name = params[:auth][:account_name]

    auth_info = PlaidService.instance.exchange_public_token(public_token)

    @account = BankAccount.new(
      plaid_access_token: auth_info.access_token,
      plaid_item_id: auth_info.item_id,
      plaid_account_id: account_id,
      name: account_name
    )

    authorize @account

    if @account.save
      redirect_to @account
    else
      redirect_to action: :new
    end
  end

  def index
    authorize BankAccount
  end

  def show
    @account = BankAccount.find(params[:id])
    authorize @account
  end

  def reauthenticate
    @account = BankAccount.find(params[:bank_account_id])
    authorize @account

    @public_token = PlaidService.instance.client.item.public_token.create(
      @account.plaid_access_token
    ).public_token
  end

  private

  def set_link_vars
    @client_name = PlaidService.instance.client_name
    @link_env = PlaidService.instance.env
    @public_key = PlaidService.instance.public_key
    @product = ['transactions'].to_json.html_safe
  end
end
