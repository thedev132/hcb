class GSuiteAccountsController < ApplicationController
  # GET /g_suite_accounts
  def index
    @g_suite_accounts = GSuiteAccount.all
  end

  private
    def g_suite_account_params
      params.require(:g_suite_account).permit(:address, :accepted_at, :rejected_at, :g_suite_id)
    end
end
