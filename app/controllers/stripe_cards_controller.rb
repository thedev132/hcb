# frozen_string_literal: true

class StripeCardsController < ApplicationController
  def index
    @cards = StripeCard.all
    authorize @cards
  end

  # async frame for shipment tracking
  def shipping
    if params[:event_id] # event card overview page
      @event = Event.friendly.find(params[:event_id])
      authorize @event
      @stripe_cards = @event.stripe_cards.physical_shipping
    else # my cards page
      # Only show shipping for phyiscal cards if the eta is in the future (or 1 week after)
      @stripe_cards = current_user.stripe_cards.physical_shipping.reject do |sc|
        eta = sc.stripe_obj[:shipping][:eta]
        !eta || Time.at(eta) < 1.week.ago
      end
      skip_authorization # do not force pundit
    end
    render :shipping, layout: false
  end

  def freeze
    @card = StripeCard.find(params[:stripe_card_id])
    authorize @card

    if @card.freeze!
      flash[:success] = "Card frozen"
      redirect_to @card
    else
      render :show, status: :unprocessable_entity
    end
  end

  def defrost
    @card = StripeCard.find(params[:stripe_card_id])
    authorize @card

    if @card.defrost!
      flash[:success] = "Card defrosted"
      redirect_to @card
    else
      render :show, status: :unprocessable_entity
    end
  end

  def activate
    @card = StripeCard.find(params[:stripe_card_id])
    authorize @card

    # Does this card replace another card? If so, attempt to cancel the old card
    if @card&.replacement_for
      suppress(Stripe::InvalidRequestError) do
        @card.replacement_for.cancel!
      end
    end

    if @card.activate!
      flash[:success] = "Card activated!"
      confetti!
      redirect_to @card
    else
      render :show, status: :unprocessable_entity
    end
  end

  def show
    @card = StripeCard.includes(:event, :user).find(params[:id])


    authorize @card

    if params[:show_details] == "true"
      ahoy.track "Card details shown", stripe_card_id: @card.id
    end

    @show_card_details = params[:show_details] == "true"
    @event = @card.event

    @hcb_codes = @card.hcb_codes
                      .includes(canonical_pending_transactions: [:raw_pending_stripe_transaction], canonical_transactions: { hashed_transactions: [:raw_stripe_transaction] })
                      .page(params[:page]).per(25)

  end

  def new
    @event = Event.friendly.find(params[:event_id])

    authorize @event, :user_or_admin?, policy_class: EventPolicy
  end

  def create
    event = Event.friendly.find(params[:stripe_card][:event_id])
    authorize event, :user_or_admin?, policy_class: EventPolicy

    sc = params[:stripe_card]

    return redirect_back fallback_location: event_cards_new_path(event), flash: { error: "Event is in Playground Mode" } if event.demo_mode?
    return redirect_back fallback_location: event_cards_new_path(event), flash: { error: "Invalid country" } unless %w(US CA).include? sc[:stripe_shipping_address_country]

    ::StripeCardService::Create.new(
      current_user: current_user,
      current_session: current_session,
      event_id: event.id,
      card_type: sc[:card_type],
      stripe_shipping_name: sc[:stripe_shipping_name],
      stripe_shipping_address_city: sc[:stripe_shipping_address_city],
      stripe_shipping_address_state: sc[:stripe_shipping_address_state],
      stripe_shipping_address_line1: sc[:stripe_shipping_address_line1],
      stripe_shipping_address_line2: sc[:stripe_shipping_address_line2],
      stripe_shipping_address_postal_code: sc[:stripe_shipping_address_postal_code],
      stripe_shipping_address_country: sc[:stripe_shipping_address_country],
    ).run

    redirect_to event_cards_overview_path(event), flash: { success: "Card was successfully created." }
  rescue => e
    Airbrake.notify(e)

    redirect_to event_cards_new_path(event), flash: { error: e.message }
  end

  def edit
    @card = StripeCard.find(params[:stripe_card_id])
    @event = @card.event
    authorize @card
  end

  def update_name
    card = StripeCard.find(params[:stripe_card_id])
    authorize card
    name = params[:stripe_card][:name]
    name = nil unless name.present?
    updated = card.update(name: name)

    redirect_to stripe_card_url(card), flash: updated ? { success: "Card's name has been successfully updated!" } : { error: "Card's name could not be updated" }
  end

  private

  def suggested(field)
    return nil unless current_user

    ecr = EmburseCardRequest.where(creator_id: current_user&.id)
    case field
    when :phone_number
      current_user.phone_number
    when :name
      current_user.full_name
    when :line1
      current_user&.stripe_cardholder&.stripe_billing_address_line1 ||
        ecr&.last&.shipping_address_street_one
    when :line2
      current_user&.stripe_cardholder&.stripe_billing_address_line2 ||
        ecr&.last&.shipping_address_street_two
    when :city
      current_user&.stripe_cardholder&.stripe_billing_address_city ||
        ecr&.last&.shipping_address_city
    when :state
      current_user&.stripe_cardholder&.stripe_billing_address_state ||
        ecr&.last&.shipping_address_state
    when :postal_code
      current_user&.stripe_cardholder&.stripe_billing_address_postal_code ||
        ecr&.last&.shipping_address_zip
    when :country
      current_user&.stripe_cardholder&.stripe_billing_address_country ||
        ("US" if ecr.any?)
    else
      nil
    end
  end

  # Only allow a trusted parameter "white list" through.
  def stripe_card_params
    params.require(:stripe_card).permit(
      :event_id,
      :card_type,
      :stripe_cardholder_id,
      :stripe_shipping_name,
      :stripe_shipping_address_city,
      :stripe_shipping_address_line1,
      :stripe_shipping_address_postal_code,
      :stripe_shipping_address_line2,
      :stripe_shipping_address_state
    )
  end

end
