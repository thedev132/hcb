class GSuiteAccountsController < ApplicationController
  def index
    @g_suite_accounts = GSuiteAccount.all
  end

  def verify
    email = params[:email]
    @g_suite_account = GSuiteAccount.select{|account| account.full_email_address == email}
    @g_suite_account.verified_at = Time.now
    if @g_suite_account.save
      GSuiteAccountMailer.verify(recipient: @g_suite_account.full_email_address).send_later
      flash[:success] = 'Email verified!'
      redirect_to @g_suite_account.g_suite.event
    else
      flash[:error] = 'Email not found!'
    end
  end

  def full_email_address
    "#{address}@#{g_suite.domain}"
  end

  private
    def g_suite_account_params
      params.require(:g_suite_account).permit(:address, :accepted_at, :rejected_at, :g_suite_id)
    end
end
