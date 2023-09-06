# frozen_string_literal: true

require "net/http"

class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:branding, :brand_guidelines, :faq]
  skip_before_action :redirect_to_onboarding, only: [:branding, :brand_guidelines, :faq]

  def index
    if signed_in?
      @service = StaticPageService::Index.new(current_user:)

      @events = @service.events
      @organizer_positions = @service.organizer_positions.not_hidden
      @invites = @service.invites

      @show_event_reorder_tip = current_user.organizer_positions.where.not(sort_index: nil).none?

      @hcb_expansion = Rails.cache.read("hcb_acronym_expansions")&.sample || "Hack Club Buckaroos"

    end
    if admin_signed_in?
      @transaction_volume = CanonicalTransaction.included_in_stats.sum("@amount_cents")
    end
  end

  def brand_guidelines
    @logos = [
      { name: "Original Light", criteria: "For white or light colored backgrounds.", background: "smoke" },
      { name: "Original Dark", criteria: "For black or dark colored backgrounds.", background: "black" },
      { name: "Outlined Black", criteria: "For white or light colored backgrounds.", background: "snow" },
      { name: "Outlined White", criteria: "For black or dark colored backgrounds.", background: "black" }
    ]
    @icons = [
      { name: "Icon Original", criteria: "The original HCB logo.", background: "smoke" },
      { name: "Icon Dark", criteria: "HCB logo in dark mode.", background: "black" }
    ]
    @event_name = signed_in? && current_user.events.first&.name || "Hack Pennsylvania"
    @event_slug = signed_in? && current_user.events.first&.slug || "hack-pennsylvania"
  end

  def faq
  end

  def my_cards
    flash[:success] = "Card activated!" if params[:activate]
    @stripe_cards = current_user.stripe_cards.includes(:event)
    @emburse_cards = current_user.emburse_cards.includes(:event)
  end

  # async frame
  def my_missing_receipts_list
    @missing_receipt_ids = []

    current_user.stripe_cards.map do |card|
      card.hcb_codes.missing_receipt.each do |hcb_code|
        next unless hcb_code.receipt_required?

        @missing_receipt_ids << hcb_code.id
        break unless @missing_receipt_ids.size < 5
      end
    end
    @missing = HcbCode.where(id: @missing_receipt_ids)
    if @missing.any?
      render :my_missing_receipts_list, layout: !request.xhr?
    else
      head :ok
    end
  end

  # async frame
  def my_missing_receipts_icon
    @missing_receipt_count ||= begin
      count = 0

      stripe_cards = current_user.stripe_cards.includes(:event)
      emburse_cards = current_user.emburse_cards.includes(:event)

      (stripe_cards + emburse_cards).each do |card|
        card.hcb_codes.missing_receipt.each do |hcb_code|
          next unless hcb_code.receipt_required?

          count += 1
        end
      end

      emojis = {
        "🤡": 300,
        "💀": 200,
        "😱": 100,
      }
      emojis.find { |emoji, value| count >= value }&.first || count
    end

    render :my_missing_receipts_icon, layout: false
  end

  def my_inbox
    user_cards = current_user.stripe_cards + current_user.emburse_cards
    user_hcb_code_ids = user_cards.flat_map { |card| card.hcb_codes.pluck(:id) }
    user_hcb_codes = HcbCode.where(id: user_hcb_code_ids)

    hcb_codes_missing_ids = user_hcb_codes.missing_receipt.filter(&:receipt_required?).pluck(:id)
    hcb_codes_missing = HcbCode.where(id: hcb_codes_missing_ids).order(created_at: :desc)

    @count = hcb_codes_missing.count # Total number of HcbCodes missing receipts
    @hcb_codes = hcb_codes_missing.page(params[:page]).per(params[:per] || 20)

    @card_hcb_codes = @hcb_codes.group_by { |hcb| hcb.card.to_global_id.to_s }
    @cards = GlobalID::Locator.locate_many(@card_hcb_codes.keys)
    # Ideally we'd preload (includes) events for @cards, but that isn't
    # supported yet: https://github.com/rails/globalid/pull/139

    if Flipper.enabled?(:receipt_bin_2023_04_07, current_user)
      @receipts = Receipt.where(user: current_user, receiptable: nil)

      @pairings = @receipts.map do |receipt|
        pairings = receipt.suggested_pairings.order(distance: :asc)
        next if pairings.ignored.count > 2

        pairing = pairings.unreviewed.first
        next if pairing.nil?
        next if pairing.distance > 3000

        pairing
      end.compact
    end

    if flash[:popover]
      @popover = flash[:popover]
      flash.delete(:popover)
    end
  end

  def receipt
    if params[:file] # Ignore if no files were uploaded
      ::ReceiptService::Create.new(
        uploader: current_user,
        attachments: params[:file],
        upload_method: params[:upload_method]
      ).run!

      if params[:show_link]
        flash[:success] = { text: "#{"Receipt".pluralize(params[:file].length)} added!", link: hcb_code_path(@hcb_code), link_text: "View" }
      else
        flash[:success] = "#{"Receipt".pluralize(params[:file].length)} added!"
      end
    end

    return redirect_to params[:redirect_url] if params[:redirect_url]

    redirect_back

  rescue => e
    notify_airbrake(e)

    flash[:error] = e.message
    return redirect_to params[:redirect_url] if params[:redirect_url]

    redirect_back
  end

  def stripe_charge_lookup
    charge_id = params[:id]
    @payment = Invoice.find_by(stripe_charge_id: charge_id)

    # No invoice with that charge id? Maybe we can find a donation payment with that charge?
    # Donations don't store charge id, but they store payment intent, and we can link it with the charge's payment intent on stripe
    unless @payment
      payment_intent_id = StripeService::Charge.retrieve(charge_id)["payment_intent"]
      @payment = Donation.find_by(stripe_payment_intent_id: payment_intent_id)
    end

    @event = @payment.event

    render json: {
      event_id: @event.id,
      event_name: @event.name,
      payment_type: @payment.class.name,
      payment_id: @payment.id
    }
  rescue StripeService::InvalidRequestError => e
    render json: {
      event_id: nil
    }
  end

  def feedback
    message = params[:message]
    share_email = params[:share_email] || "1"

    feedback = {
      "Share your idea(s)" => message,
    }

    if share_email == "1"
      feedback["Name"] = current_user.name
      feedback["Email"] = current_user.email
      feedback["Organization"] = current_user.events.first&.name
    end

    Feedback.create(feedback)

    head :no_content
  end

end
