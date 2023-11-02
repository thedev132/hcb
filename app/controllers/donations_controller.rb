# frozen_string_literal: true

require "csv"

class DonationsController < ApplicationController
  include SetEvent
  include Rails::Pagination

  skip_after_action :verify_authorized, except: [:start_donation, :make_donation]
  skip_before_action :signed_in_user
  before_action :set_donation, only: [:show]
  before_action :set_event, only: [:start_donation, :make_donation, :qr_code]
  before_action :check_dark_param
  skip_before_action :redirect_to_onboarding

  # Rationale: the session doesn't work inside iframes (because of third-party cookies)
  skip_before_action :verify_authenticity_token, only: [:start_donation, :make_donation, :finish_donation]

  # Allow embedding donation pages inside iframes
  content_security_policy(only: [:start_donation, :make_donation, :finish_donation]) do |policy|
    policy.frame_ancestors "*"
  end

  permissions_policy do |p|
    # Allow stripe.js to wrap PaymentRequest in non-safari browsers.
    p.payment    :self
    # Allow embedded donation pages to be fullscreened
    p.fullscreen :self
  end

  invisible_captcha only: [:make_donation], honeypot: :subtitle, on_timestamp_spam: :redirect_to_404

  # GET /donations/1
  def show
    authorize @donation
    @hcb_code = HcbCode.find_or_create_by(hcb_code: @donation.hcb_code)
    redirect_to hcb_code_path(@hcb_code.hashid)
  end

  def start_donation
    if !@event.donation_page_enabled
      return not_found
    end

    @donation = Donation.new(
      name: params[:name],
      email: params[:email],
      amount: params[:amount],
      message: params[:message],
      event: @event,
      ip_address: request.ip,
      user_agent: request.user_agent
    )

    authorize @donation

    @monthly = params[:monthly].present?

    if @monthly
      @recurring_donation = @event.recurring_donations.build
    end

    @placeholder_amount = "%.2f" % (DonationService::SuggestedAmount.new(@event, monthly: @monthly).run / 100.0)
  end

  def make_donation
    d_params = donation_params
    d_params[:amount] = Monetize.parse(donation_params[:amount]).cents

    if d_params[:name] == "aser ras"
      skip_authorization
      redirect_to root_url and return
    end

    d_params[:ip_address] = request.ip
    d_params[:user_agent] = request.user_agent

    @donation = Donation.new(d_params)
    @donation.event = @event

    authorize @donation

    if @donation.save
      redirect_to finish_donation_donations_path(@event, @donation.url_hash)
    else
      render :start_donation, status: :unprocessable_entity
    end
  end

  def finish_donation

    @donation = Donation.find_by!(url_hash: params["donation"])

    # We don't use set_event here to prevent a UI vulnerability where a user could create a donation on one org and make it look like another org by changing the slug
    # https://github.com/hackclub/hcb/issues/3197
    @event = @donation.event

    if @donation.status == "succeeded"
      flash[:info] = "You tried to access the payment page for a donation that’s already been sent."
      redirect_to start_donation_donations_path(@event)
    end

    if cookies[:donation_dark]
      cookies.delete(:donation_dark)
    end
  end

  def qr_code
    qrcode = RQRCode::QRCode.new(start_donation_donations_url(@event))

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      fill: "white",
      module_px_size: 6,
      size: 300
    )

    send_data png, filename: "#{@event.name} Donate.png",
      type: "image/png", disposition: "inline"
  end

  def refund
    @donation = Donation.find(params[:id])
    @hcb_code = @donation.local_hcb_code

    ::DonationService::Refund.new(donation_id: @donation.id, amount: Monetize.parse(params[:amount]).cents).run

    redirect_to hcb_code_path(@hcb_code.hashid), flash: { success: "The refund process has been queued for this donation." }
  end

  def export
    @event = Event.friendly.find(params[:event])

    authorize @event.donations.first

    respond_to do |format|
      format.csv { stream_donations_csv }
      format.json { stream_donations_json }
    end
  end

  private

  def stream_donations_csv
    set_file_headers_csv
    set_streaming_headers

    response.status = 200

    self.response_body = donations_csv
  end

  def stream_donations_json
    set_file_headers_json
    set_streaming_headers

    response.status = 200

    self.response_body = donations_json
  end

  def set_file_headers_csv
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=donations.csv"
  end

  def set_file_headers_json
    headers["Content-Type"] = "application/json"
    headers["Content-disposition"] = "attachment; filename=donations.json"
  end

  def donations_csv
    ::DonationService::Export::Csv.new(event_id: @event.id).run
  end

  def donations_json
    ::DonationService::Export::Json.new(event_id: @event.id).run
  end

  def set_donation
    @donation = Donation.find(params[:id])
  end

  def check_dark_param
    if params[:dark].present? || cookies[:donation_dark]
      @dark = true
      cookies[:donation_dark] = true
    end
  end

  def donation_params
    params.require(:donation).permit(:email, :name, :amount, :message)
  end

  def redirect_to_404
    raise ActionController::RoutingError.new("Not Found")
  end

end
