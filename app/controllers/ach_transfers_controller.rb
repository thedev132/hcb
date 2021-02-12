class AchTransfersController < ApplicationController
  before_action :set_ach_transfer, except: [:new, :create, :index]
  before_action :set_event, only: [:new, :create]
  skip_before_action :signed_in_user

  # GET /ach_transfers
  def index
    authorize AchTransfer
    @ach_transfers = AchTransfer.all
  end

  # GET /ach_transfers/1
  def show
    authorize @ach_transfer

    @commentable = @ach_transfer
    @comments = @commentable.comments
    @comment = Comment.new
  end

  # GET /ach_transfers/new
  def new
    @ach_transfer = AchTransfer.new(event: @event)
    authorize @ach_transfer
  end

  # POST /ach_transfers
  def create
    authorize @event, policy_class: AchTransferPolicy

    attrs = {
      event_id: @event.id,
      routing_number: ach_transfer_params[:routing_number],
      account_number: ach_transfer_params[:account_number],
      bank_name: ach_transfer_params[:bank_name],
      recipient_name: ach_transfer_params[:recipient_name],
      recipient_tel: ach_transfer_params[:recipient_tel],
      amount_cents: (ach_transfer_params[:amount].to_f * 100).to_i,
      payment_for: ach_transfer_params[:payment_for],
      current_user: current_user
    }
    ach_transfer = AchTransferService::Create.new(attrs).run

    flash[:success] = 'ACH Transfer successfully submitted.'

    redirect_to event_transfers_path(@event)
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    flash[:error] = e.message

    redirect_to new_event_ach_transfer_path(@event)
  end

  def approve
    authorize @ach_transfer

    if @ach_transfer.approve! && @ach_transfer.update(ach_approve_params)
      flash[:sucesss] = 'ACH Transfer successfully approved!'
      redirect_to ach_transfers_url
    else
      redirect_to ach_transfer_start_approval_path(@ach_transfer)
    end
  end

  def reject
    authorize @ach_transfer

    if @ach_transfer.rejected?
      flash[:error] = 'This ACH Transfer has already been rejected!'
      redirect_to ach_transfers_path
      return
    end

    @ach_transfer.reject!

    redirect_to ach_transfers_path
  end

  def start_approval
    authorize @ach_transfer
  end

  private

  def set_ach_transfer
    @ach_transfer = AchTransfer.find(params[:id] || params[:ach_transfer_id])
    @event = @ach_transfer.event
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def ach_transfer_params
    params.require(:ach_transfer).permit(:routing_number, :account_number, :bank_name, :recipient_name, :recipient_tel, :amount, :payment_for)
  end

  def ach_approve_params
    params.require(:ach_transfer).permit(:scheduled_arrival_date)
  end
end
