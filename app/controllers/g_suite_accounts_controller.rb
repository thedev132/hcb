class GSuiteAccountsController < ApplicationController
  before_action :set_g_suite_account, only: [:show, :edit, :update, :destroy]

  # GET /g_suite_accounts
  def index
    @g_suite_accounts = GSuiteAccount.all
  end

  # GET /g_suite_accounts/1
  def show
  end

  # GET /g_suite_accounts/new
  def new
    @g_suite_account = GSuiteAccount.new
  end

  # GET /g_suite_accounts/1/edit
  def edit
  end

  # POST /g_suite_accounts
  def create
    @g_suite_account = GSuiteAccount.new(g_suite_account_params)

    if @g_suite_account.save
      redirect_to @g_suite_account, notice: 'G suite account was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /g_suite_accounts/1
  def update
    if @g_suite_account.update(g_suite_account_params)
      redirect_to @g_suite_account, notice: 'G suite account was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /g_suite_accounts/1
  def destroy
    @g_suite_account.destroy
    redirect_to g_suite_accounts_url, notice: 'G suite account was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_g_suite_account
      @g_suite_account = GSuiteAccount.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def g_suite_account_params
      params.require(:g_suite_account).permit(:address, :accepted_at, :rejected_at, :g_suite_id)
    end
end
