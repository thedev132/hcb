class AchTransfersController < ApplicationController
  before_action :set_ach_transfer, except: [:new, :create, :index]
  before_action :set_event, only: [:new, :create]
  skip_before_action :signed_in_user

  # GET /ach_transfers/1
  def show
    authorize @ach_transfer

    @commentable = @ach_transfer
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def transfer_confirmation_letter
    authorize @ach_transfer

    @commentable = @ach_transfer
    @comments = @commentable.comments
    @comment = Comment.new

    respond_to do |format|
      format.html do
        redirect_to @ach_transfer
      end

      format.pdf do
        if @ach_transfer.deposited?
          render pdf: 'transfer_confirmation_letter', page_height: '11in', page_width: '8.5in'
        else
          redirect_to @ach_transfer
        end
      end

      # works, but not being used at the moment
      format.png do
        if @ach_transfer.deposited?
          send_data ::AchTransferService::PreviewTransferConfirmationLetter.new(ach_transfer: @ach_transfer, event: @event).run, filename: 'transfer_confirmation_letter.png'
        else
          redirect_to @ach_transfer
        end
      end

    end
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
end
