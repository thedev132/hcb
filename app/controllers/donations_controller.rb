class DonationsController < ApplicationController
  include Rails::Pagination
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  skip_after_action :verify_authorized, except: [:show]
  skip_before_action :signed_in_user, except: [:show]
  before_action :set_event, only: [:start_donation, :make_donation, :finish_donation, :qr_code]
  before_action :allow_iframe, except: [:show, :index]

  # GET /donations/1
  def show
    authorize @donation
    @event = @donation.event

    @commentable = @donation
    @comments = @commentable.comments.includes(:user)
    @comment = Comment.new
  end

  def start_donation
    if !@event.donation_page_enabled
      return not_found
    end

    @donation = Donation.new
  end

  # GET /donations
  def index
    authorize Donation
    @donations = paginate(Donation.all.order(created_at: :desc))
  end

  def make_donation
    d_params = public_donation_params
    d_params[:amount] = (public_donation_params[:amount].to_f * 100.to_i)

    @donation = Donation.new(d_params)
    @donation.event = @event

    if @donation.save
      redirect_to finish_donation_donations_path(@event, @donation.url_hash)
    else
      render :start_donation
    end
  end

  def finish_donation
    @donation = Donation.find_by_url_hash(params['donation'])

    if @donation.status == 'succeeded'
      flash[:info] = 'You tried to access the payment page for a donation that’s already been sent.'
      redirect_to start_donation_donations_path(@event)
    end
  end

  def accept_donation_hook
    # only proceed if payment intent is a donation and not an invoice
    return unless request.params['data']['object']['metadata']['donation'].present?

    # get donation to process
    donation = Donation.find_by_stripe_payment_intent_id(request.params['data']['object']['id'])

    pi = StripeService::PaymentIntent.retrieve(
      id: donation.stripe_payment_intent_id,
      expand: ['charges.data.balance_transaction'])
    donation.set_fields_from_stripe_payment_intent(pi)
    donation.save

    DonationService::Queue.new(donation_id: donation.id).run # queues/crons payout. DEPRECATE. most is unnecessary if we just run in a cron

    donation.send_receipt!

    return true
  end

  def qr_code
    qrcode = RQRCode::QRCode.new("https://bank.hackclub.com" + start_donation_donations_path(@event.slug))

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      fill: 'white',
      module_px_size: 6,
      size: 300
    )

    send_data png, filename: "#{@event.name} Donate.png",
      type: 'image/png', disposition: 'inline'
  end

  private

  def set_event
    @event = Event.find(params['event_name'])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_donation
    @donation = Donation.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def donation_params
    params.require(:donation).permit(:email, :name, :amount, :amount_received, :status, :stripe_client_secret)
  end

  def public_donation_params
    params.require(:donation).permit(:email, :name, :amount, :message)
  end

  def allow_iframe
    response.headers.delete 'X-Frame-Options'
  end
end
