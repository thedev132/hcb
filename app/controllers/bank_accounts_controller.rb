class BankAccountsController < ApplicationController
  def new
    @link_env = PlaidService.instance.env
    @public_key = PlaidService.instance.public_key
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

    if @account.save
      redirect_to @account
    else
      redirect_to action: :new
    end
  end

  def show
    @account = BankAccount.find(params[:id])
  end
end
