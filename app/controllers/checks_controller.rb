class ChecksController < ApplicationController
  before_action :set_check, except: %i[index new create export]
  before_action :set_event, only: %i[new create]
  skip_before_action :signed_in_user

  # GET /checks
  def index
    authorize Check
    @checks = Check.all.order(created_at: :desc)
  end

  # GET /checks/new
  def new
    raise ActiveRecord::RecordNotFound unless using_transaction_engine_v2?

    @lob_address = LobAddress.new(event: @event)
    @check = Check.new(lob_address: @lob_address)

    authorize @check
  end

  # POST /checks
  def create
    raise ActiveRecord::RecordNotFound unless using_transaction_engine_v2?

    authorize @event, policy_class: CheckPolicy

    # 1. Update/Create LobAddress
    lob_address_params = filtered_params[:lob_address_attributes].merge(event: @event)
    lob_address_params['country'] = 'US'
    @lob_address = LobAddress.find_or_initialize_by(id: lob_address_params[:id], event: @event)
    @lob_address.update!(lob_address_params)

    # 2. Create Check
    attrs = {
      event_id: @event.id,
      lob_address_id: @lob_address.id,

      memo: filtered_params[:memo],
      amount_cents: (filtered_params[:amount].to_f * 100).to_i,

      current_user: current_user
    }
    CheckService::Create.new(attrs).run

    flash[:success] = 'Your check is on its way!'

    redirect_to event_transfers_path(@event)
  end

  # GET /checks/1
  def show
    authorize @check

    @commentable = @check
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def positive_pay_csv
    authorize @check

    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=check-#{@check.id}-#{@check.check_number}.csv"
    headers["X-Accel-Buffering"] = "no"
    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")

    response.status = 200

    self.response_body = ::CheckService::PositivePay::Csv.new(check_id: @check.id).run
  end

  def view_scan
    authorize @check

    redirect_to @check.url
  end

  def mark_in_transit
    authorize @check

    @check.mark_in_transit!

    redirect_to @check
  end

  def start_void
    authorize @check

    if @check.voided?
      flash[:info] = 'You already voided that check!'
      redirect_to event_transfers_path(@check.event)
      return
    end
  end

  def void
    authorize @check

    if @check.voided?
      flash[:success] = 'You already voided that check!'
      redirect_to event_transfers_path(@check.event)
      return false
    end

    if @check.void!
      flash[:success] = 'Check successfully voided.'
      redirect_to event_transfers_path(@check.event)
    else
      render :start_void
    end
  end

  def refund_get
    authorize @check
  end

  def refund
    authorize @check

    if @check.refund!
      flash[:sucesss] = "Check has been refunded!"
      redirect_to checks_path
    else
      redirect_to :refund
    end
  end

  private

  def set_check
    @check = Check.includes(:creator).find(params[:id] || params[:check_id])
    @event = @check.event
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def filtered_params
    params.require(:check).permit(
      :memo,
      :amount,
      :payment_for,
      :lob_address_id,
      lob_address_attributes: [
        :name,
        :address1,
        :address2,
        :city,
        :state,
        :zip,
        :id
      ]
    )
  end
end
