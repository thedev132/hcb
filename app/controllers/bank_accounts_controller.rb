# frozen_string_literal: true

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

  def update
    @bank_account = BankAccount.find(params[:id])
    authorize @bank_account

    if @bank_account.update(bank_account_update_params)
      if @bank_account.should_sync?
        flash[:success] = "Bank account transaction syncing is enabled."
      else
        flash[:muted] = "Bank account transaction syncing is paused."
      end
      redirect_to @bank_account
    else
      render "show"
    end
  end

  def index
    authorize BankAccount
  end

  def show
    @account = BankAccount.find(params[:id])
    authorize @account
    @transactions = @account.transactions.includes(:event)
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
    @product = ["transactions"].to_json.html_safe
  end

  def bank_account_update_params
    params.require(:bank_account).permit(:should_sync)
  end
end
