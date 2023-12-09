# frozen_string_literal: true

class AchTransfersController < ApplicationController
  before_action :set_ach_transfer, except: [:new, :create, :index, :validate_routing_number]
  before_action :set_event, only: [:new, :create]
  skip_before_action :signed_in_user, except: [:validate_routing_number]
  skip_after_action :verify_authorized, only: [:validate_routing_number]

  # GET /ach_transfers/1
  def show
    authorize @ach_transfer

    redirect_to @ach_transfer.local_hcb_code
  end

  def transfer_confirmation_letter
    authorize @ach_transfer

    respond_to do |format|
      unless @ach_transfer.deposited?
        redirect_to @ach_transfer and return
      end

      format.html do
        redirect_to @ach_transfer
      end

      format.pdf do
        render pdf: "ACH Transfer ##{@ach_transfer.id} Confirmation Letter (#{@event.name} to #{@ach_transfer.recipient_name} on #{@ach_transfer.canonical_pending_transaction.date.strftime("%B #{@ach_transfer.canonical_pending_transaction.date.day.ordinalize}, %Y")})", page_height: "11in", page_width: "8.5in"
      end

      # works, but not being used at the moment
      format.png do
        send_data ::AchTransferService::PreviewTransferConfirmationLetter.new(ach_transfer: @ach_transfer, event: @event).run, filename: "transfer_confirmation_letter.png"
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
    @ach_transfer = @event.ach_transfers.build(ach_transfer_params.merge(creator: current_user))

    authorize @ach_transfer

    if @ach_transfer.save
      redirect_to event_transfers_path(@event), flash: { success: "ACH transfer successfully submitted." }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @ach_transfer

    @ach_transfer.mark_rejected!

    redirect_to @ach_transfer.local_hcb_code
  end

  def validate_routing_number
    return render json: { valid: true } if params[:value].empty?
    return render json: { valid: false, hint: "Bank not found for this routing number." } unless /\A\d{9}\z/.match?(params[:value])

    banks = Increase::RoutingNumbers.list(routing_number: params[:value])

    valid = banks.size > 0

    render json: {
      valid:,
      hint: valid ? banks.first&.dig("name") : "Bank not found for this routing number.",
    }
  rescue => e
    notify_airbrake(e)
    render json: { valid: true }
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
    params.require(:ach_transfer).permit(:routing_number, :account_number, :bank_name, :recipient_name, :amount_money, :payment_for, :scheduled_on)
  end

end
