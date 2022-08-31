# frozen_string_literal: true

class StripeController < ApplicationController
  protect_from_forgery except: :webhook # ignore csrf checks
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:webhook] # do not require logged in user

  def webhook
    payload = request.body.read
    sig_header = request.headers['Stripe-Signature']
    event = nil

    begin
      event = StripeService.construct_webhook_event(payload, sig_header)
      method = "handle_" + event["type"].tr(".", "_")
      self.send method, event
    rescue JSON::ParserError => e
      head 400
      Airbrake.notify(e)
      return
    rescue NoMethodError => e
      puts e
      Airbrake.notify(e)
      head 200 # success so that stripe doesn't retry (method is unsupported by Bank)
      return
    rescue Stripe::SignatureVerificationError
      head 400
      return
    end

    head 200
  end

  private

  def handle_issuing_authorization_request(event)
    ::StripeAuthorizationService::Webhook::HandleIssuingAuthorizationRequest.new(stripe_event: event).run
  end

  def handle_issuing_authorization_created(event)
    auth_id = event[:data][:object][:id]

    # DEPRECATED: put the transaction on the v1 ledger
    ::StripeAuthorizationJob::Deprecated::CreateFromWebhook.perform_later(auth_id)

    # put the transaction on the pending ledger in almost realtime
    ::StripeAuthorizationJob::CreateFromWebhook.perform_later(auth_id)
  end

  def handle_issuing_authorization_updated(event)
    # This is to listen for edge-cases like multi-capture TXs
    # https://stripe.com/docs/issuing/purchases/transactions
    auth = event[:data][:object]
    sa = StripeAuthorization.find_or_initialize_by(stripe_id: auth[:id])
    sa.sync_from_stripe!
    sa.save
  end

  def handle_issuing_transaction_created(event)
    tx = event[:data][:object]
    amount = tx[:amount]
    return unless amount < 0

    TopupStripeJob.perform_later
  end

  def handle_issuing_card_updated(event)
    card = StripeCard.find_by(stripe_id: event[:data][:object][:id])
    card.sync_from_stripe!
    card.save
  end

  def handle_charge_succeeded(event)
    charge = event[:data][:object]
    ::PartnerDonationService::HandleWebhookChargeSucceeded.new(charge).run
  end

  def handle_invoice_paid(event)
    invoice = Invoice.find_by(stripe_invoice_id: event[:data][:object][:id])
    return unless invoice

    # Mark invoice as paid
    InvoiceService::OpenToPaid.new(invoice_id: invoice.id).run

    unless invoice.manually_marked_as_paid?
      # Import to the ledger
      rpit = ::PendingTransactionEngine::RawPendingInvoiceTransactionService::Invoice::ImportSingle.new(invoice: invoice).run
      cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Invoice.new(raw_pending_invoice_transaction: rpit).run
      ::PendingEventMappingEngine::Map::Single::Invoice.new(canonical_pending_transaction: cpt).run
    end
  end

  def handle_charge_dispute_funds_withdrawn(event)
    # A donor has disputed a charge. Oh no!

    # TODO: properly handle disputes

    dispute = event[:data][:object]

    payment_intent = Partners::Stripe::PaymentIntents::Show.new(id: dispute[:payment_intent]).run

    if payment_intent.metadata[:donation].present?
      # It's a donation

      donation = Donation.find_by(stripe_payment_intent_id: dispute[:payment_intent])

      return Airbrake.notify("Received charge dispute on nonexistent donation") if donation.nil?

      # Let's un-front the transaction.
      donation.canonical_pending_transactions.update_all(fronted: false)
    else
      # It's an invoice

      invoice = Invoice.find_by(stripe_charge_id: dispute[:charge])

      return Airbrake.notify("Received charge dispute on nonexistent invoice") if invoice.nil?

      invoice.canonical_pending_transactions.update_all(fronted: false)
    end

  end

end
