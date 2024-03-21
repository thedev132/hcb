# frozen_string_literal: true

require "net/http"

class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:branding, :faq, :roles]
  skip_before_action :redirect_to_onboarding, only: [:branding, :faq, :roles]

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

  def branding
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

  def roles
  end

  def faq
  end

  def my_cards
    @stripe_cards = current_user.stripe_cards.includes(:event)
    @emburse_cards = current_user.emburse_cards.includes(:event)
  end

  # async frame
  def my_missing_receipts_list
    @missing = current_user.transactions_missing_receipt

    if @missing.any?
      render :my_missing_receipts_list, layout: !request.xhr?
    else
      head :ok
    end
  end

  # async frame
  def my_missing_receipts_icon
    count = current_user.transactions_missing_receipt.count

    emojis = {
      "🤡": 300,
      "💀": 200,
      "😱": 100,
    }

    @missing_receipt_count = emojis.find { |emoji, value| count >= value }&.first || count

    render :my_missing_receipts_icon, layout: false
  end

  def my_inbox
    @count = current_user.transactions_missing_receipt.count
    @hcb_codes = current_user.transactions_missing_receipt.page(params[:page]).per(params[:per] || 15)

    @card_hcb_codes = @hcb_codes.includes(:canonical_transactions, canonical_pending_transactions: :raw_pending_stripe_transaction) # HcbCode#card uses CT and PT
                                .group_by { |hcb| hcb.card.to_global_id.to_s }
    @cards = GlobalID::Locator.locate_many(@card_hcb_codes.keys, includes: :event)
                              # Order by cards with least transactions first
                              .sort_by { |card| @card_hcb_codes[card.to_global_id.to_s].count }

    if Flipper.enabled?(:receipt_bin_2023_04_07, current_user)
      @mailbox_address = current_user.active_mailbox_address
      @receipts = Receipt.in_receipt_bin.where(user: current_user)
      @pairings = current_user.receipt_bin.suggested_receipt_pairings
    end

    if flash[:popover]
      @popover = flash[:popover]
      flash.delete(:popover)
    end
  end

  def my_reimbursements
    @reports = current_user.reimbursement_reports
    @reports = @reports.pending if params[:filter] == "pending"
    @reports = @reports.where(aasm_state: ["reimbursement_approved", "reimbursed"]) if params[:filter] == "reimbursed"
    @reports = @reports.rejected if params[:filter] == "rejected"
    @reports = @reports.search(params[:q]) if params[:q].present?
    @payout_method = current_user.payout_method
  end

  def my_draft_reimbursements_icon
    @draft_reimbursements_count = current_user.reimbursement_reports.draft.count

    render :my_draft_reimbursements_icon, layout: false
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
    share_email = (params[:share_email] || "1") == "1"
    url = share_email ? "#{request.base_url}#{params[:page_path]}" : ""

    routing = Rails.application.routes.recognize_path(params[:page_path])
    location = "#{routing[:controller]}##{routing[:action]} #{routing[:id] if routing[:id] && share_email}".strip

    feedback = {
      "Share your idea(s)" => message,
      "URL"                => url,
      "Location"           => location,
    }

    if share_email
      feedback["Name"] = current_user.name
      feedback["Email"] = current_user.email
      feedback["Organization"] = current_user.events.first&.name
    end

    Feedback.create(feedback)

    head :no_content
  end

end
