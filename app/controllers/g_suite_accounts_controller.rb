class GSuiteAccountsController < ApplicationController
  before_action :set_g_suite_account, only: [ :edit, :update, :reject ]

  def index
    @g_suite_accounts = GSuiteAccount.all.order(created_at: :desc)
  end

  def create
    @g_suite = GSuite.find(params[:g_suite_id])
    @event = @g_suite.event
    @g_suite_account = GSuiteAccount.new(g_suite_account_params.merge(
      address: full_email_address(params[:g_suite_account][:address], @g_suite),
      creator: current_user,
      g_suite: @g_suite
    ))

    authorize @g_suite_account

    if @g_suite_account.save
      flash[:success] = 'G Suite account application submitted!'
    else
      flash[:error] = 'That email address is already in use.'
    end
    redirect_to event_g_suite_status_path(event_id: @event.id)
  end

  def edit
  end

  def update
    authorize @g_suite_account

    if @g_suite_account.update(g_suite_account_params)
      if @g_suite_account.previous_changes[:initial_password]
        @g_suite_account.update(accepted_at: Time.now)
        flash[:info] = 'Accepted!'
      end
      flash[:success] = 'Saved changes to G Suite Account.'
      redirect_to g_suite_accounts_path
    else
      render :edit
    end
  end

  def verify
    email = params[:email]
    @g_suite_account = GSuiteAccount.select { |account| account.full_email_address == email }
    @g_suite_account.verified_at = Time.now
    if @g_suite_account.save
      GSuiteAccountMailer.verify(recipient: @g_suite_account.full_email_address).send_later
      flash[:success] = 'Email verified!'
      redirect_to @g_suite_account.g_suite.event
    else
      flash[:error] = 'Email not found!'
    end
  end

  def reject
    authorize @g_suite_account

    @g_suite_account.rejected_at = Time.now

    if @g_suite_account.save
      flash[:success] = 'G Suite Account rejected.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to g_suite_accounts_path
  end

  private

  def set_g_suite_account
    @g_suite_account = GSuiteAccount.find(params[:g_suite_account_id] || params[:id])
  end

  def g_suite_account_params
    params.require(:g_suite_account).permit(:backup_email, :address, :accepted_at, :rejected_at, :initial_password, :g_suite_id)
  end

  def full_email_address(address, g_suite)
    "#{address}@#{g_suite.domain}"
  end
end
