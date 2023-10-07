# frozen_string_literal: true

class StripeController < ApplicationController
  protect_from_forgery except: :webhook # ignore csrf checks
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:webhook] # do not require logged in user

  def webhook
    payload = request.body.read
    sig_header = request.headers["Stripe-Signature"]

    begin
      event = StripeService.construct_webhook_event(payload, sig_header)
      method = "handle_" + event["type"].tr(".", "_")
      self.send method, event
    rescue JSON::ParserError => e
      head 400
      notify_airbrake(e)
      return
    rescue NoMethodError => e
      puts e
      notify_airbrake(e)
      head 200 # success so that stripe doesn't retry (method is unsupported by HCB)
      return
    rescue Stripe::SignatureVerificationError
      head 400
      return
    end
  end

  private

  def handle_issuing_authorization_request(event)
    approved = ::StripeAuthorizationService::Webhook::HandleIssuingAuthorizationRequest.new(stripe_event: event).run

    response.set_header "Stripe-Version", "2022-08-01"

    render json: {
      approved:
    }
  end

  def handle_issuing_authorization_created(event)
    auth_id = event[:data][:object][:id]

    # put the transaction on the pending ledger in almost realtime
    ::StripeAuthorizationJob::CreateFromWebhook.perform_later(auth_id)

    head 200
  end

  def handle_issuing_transaction_created(event)
    tx = event[:data][:object]
    amount = tx[:amount]
    return unless amount < 0

    TopupStripeJob.perform_later

    head 200
  end

  def handle_issuing_card_updated(event)
    card = StripeCard.find_by(stripe_id: event[:data][:object][:id])
    card.sync_from_stripe!
    card.save

    head 200
  end

  def handle_charge_succeeded(event)
    charge = event[:data][:object]
    ::PartnerDonationService::HandleWebhookChargeSucceeded.new(charge).run

    head 200
  end

  def handle_invoice_paid(event)
    stripe_invoice = event[:data][:object]

    if stripe_invoice.subscription.present?
      RecurringDonationService::HandleInvoicePaid.new(stripe_invoice).run
      return
    end

    invoice = Invoice.find_by(stripe_invoice_id: stripe_invoice[:id])
    return unless invoice

    # Mark invoice as paid
    InvoiceService::OpenToPaid.new(invoice_id: invoice.id).run

    unless invoice.manually_marked_as_paid?
      # Import to the ledger
      rpit = ::PendingTransactionEngine::RawPendingInvoiceTransactionService::Invoice::ImportSingle.new(invoice:).run
      cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Invoice.new(raw_pending_invoice_transaction: rpit).run
      ::PendingEventMappingEngine::Map::Single::Invoice.new(canonical_pending_transaction: cpt).run
    end

    head 200
  end

  def handle_customer_subscription_updated(event)
    recurring_donation = RecurringDonation.find_by(stripe_subscription_id: event.data.object.id)
    return unless recurring_donation

    recurring_donation.sync_with_stripe_subscription!
    recurring_donation.save!
  end

  alias_method :handle_customer_subscription_deleted, :handle_customer_subscription_updated

  def handle_setup_intent_succeeded(event)
    setup_intent = event.data.object
    return unless setup_intent.metadata.recurring_donation_id

    suppress(ActiveRecord::RecordNotFound) do
      recurring_donation = RecurringDonation.find(setup_intent.metadata.recurring_donation_id)
      StripeService::Subscription.update(recurring_donation.stripe_subscription_id, default_payment_method: setup_intent.payment_method)
      recurring_donation.sync_with_stripe_subscription!
      recurring_donation.save!

      RecurringDonationMailer.with(recurring_donation:).payment_method_changed.deliver_later
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

      return notify_airbrake("Received charge dispute on nonexistent donation") if donation.nil?

      # Let's un-front the transaction.
      donation.canonical_pending_transactions.update_all(fronted: false)
    else
      # It's an invoice

      invoice = Invoice.find_by(stripe_charge_id: dispute[:charge])

      return notify_airbrake("Received charge dispute on nonexistent invoice") if invoice.nil?

      invoice.canonical_pending_transactions.update_all(fronted: false)
    end

    head 200
  end

  def handle_charge_refunded(event)
    charge = event[:data][:object]

    donation = Donation.find_by(stripe_payment_intent_id: charge[:payment_intent])
    return unless donation

    donation.mark_refunded! unless donation.refunded?

    StripeService::Topup.create(
      amount: charge[:amount_refunded],
      currency: "usd",
      description: "Refund for donation #{donation.id}",
      statement_descriptor: "HCB-#{donation.local_hcb_code.short_code}"
    )
  end

  def handle_payment_intent_succeeded(event)
    # only proceed if payment intent is a donation and not an invoice
    return unless event.data.object.metadata[:donation].present?

    # get donation to process
    donation = Donation.find_by_stripe_payment_intent_id(event.data.object.id)

    pi = StripeService::PaymentIntent.retrieve(
      id: donation.stripe_payment_intent_id,
      expand: ["charges.data.balance_transaction"]
    )
    donation.set_fields_from_stripe_payment_intent(pi)
    donation.save!

    donation.send_receipt!

    # Import the donation onto the ledger
    rpdt = ::PendingTransactionEngine::RawPendingDonationTransactionService::Donation::ImportSingle.new(donation:).run
    cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Donation.new(raw_pending_donation_transaction: rpdt).run
    ::PendingEventMappingEngine::Map::Single::Donation.new(canonical_pending_transaction: cpt).run
  end

  def handle_source_transaction_created(event)
    stripe_source_transaction = event.data.object
    source = StripeAchPaymentSource.find_by(stripe_source_id: stripe_source_transaction.source)

    return unless source

    charge = source.charge!(stripe_source_transaction.amount)

    ach_payment = source.ach_payments.create(
      stripe_source_transaction_id: stripe_source_transaction.id,
      stripe_charge_id: charge.id,
    )

    ach_payment.create_stripe_payout!
    ach_payment.create_fee_reimbursement!

    CanonicalPendingTransaction.create(
      date: Time.at(stripe_source_transaction.created).to_date,
      event: source.event,
      amount_cents: stripe_source_transaction.amount,
      memo: "Bank transfer",
      ach_payment:
    )
  end

end
