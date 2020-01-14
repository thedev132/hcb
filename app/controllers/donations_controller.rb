class DonationsController < ApplicationController
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  skip_after_action :verify_authorized, only: [:start_donation, :make_donation, :finish_donation, :accept_donation_hook]
  skip_before_action :signed_in_user, only: [:start_donation, :make_donation, :finish_donation, :accept_donation_hook]

  # GET /donations/1
  def show
    authorize @donation
  end

  def start_donation
    @event = Event.find(params['event_name'])

    if !@event.beta_features_enabled
      return not_found
    end

    @donation = Donation.new
  end

  def make_donation
    d_params = public_donation_params
    d_params[:amount] = (public_donation_params[:amount].to_f * 100.to_i)

    @event = Event.find(params['event_name'])
    @donation = Donation.new(d_params)
    @donation.event = @event

    if @donation.save
      redirect_to finish_donation_donations_path(@event, @donation.url_hash)
    else
      render :start_donation
    end
  end

  def finish_donation
    @event = Event.find(params['event_name'])
    @donation = Donation.find_by_url_hash(params['donation'])
  end

  def accept_donation_hook
    # only proceed if payment intent is a donation and not an invoice
    return unless request.params['data']['object']['metadata']['donation'].present?

    # get donation to process
    donation = Donation.find_by_stripe_payment_intent_id(request.params['data']['object']['id'])

    pi = StripeService::PaymentIntent.retrieve(id: donation.stripe_payment_intent_id, expand: ['charges.data.balance_transaction'])
    donation.set_fields_from_stripe_payment_intent(pi)
    donation.save

    # create donation payout
    donation.queue_payout!

    donation.send_receipt!

    return true
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_donation
    @donation = Donation.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def donation_params
    params.require(:donation).permit(:email, :name, :amount, :amount_received, :status, :stripe_client_secret)
  end

  def public_donation_params
    params.require(:donation).permit(:email, :name, :amount)
  end
end
