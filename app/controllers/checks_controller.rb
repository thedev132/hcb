class ChecksController < ApplicationController
  before_action :set_check, except: %i[index new create export]
  before_action :set_event, only: %i[new create]
  skip_before_action :signed_in_user

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

      payment_for: filtered_params[:payment_for],
      memo: filtered_params[:memo],
      amount_cents: (filtered_params[:amount].to_f * 100).to_i,
      send_date: Time.now.utc + 48.hours,

      current_user: current_user
    }
    check = CheckService::Create.new(attrs).run

    flash[:success] = "Your check is scheduled to send on #{check.send_date.to_date}"

    redirect_to event_transfers_path(@event)
  rescue ArgumentError, ::Lob::InvalidRequestError => e
    flash[:error] = e.message

    redirect_to new_event_check_path(@event)
  end

  def show
    authorize @check
      
    # Comments
    @hcb_code = HcbCode.find_by(hcb_code: @check.hcb_code)
  end

  def cancel
    authorize @check

    ::CheckService::Cancel.new(check_id: @check.id).run

    redirect_to @check
  end

  def view_scan
    authorize @check

    redirect_to @check.lob_url
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
