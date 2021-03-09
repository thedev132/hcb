module PayoutService
  class Nightly
    def run
      ::Donation.succeeded.where("payout_id is null").each do |donation|
        # 1. fetch payment intent
        payment_intent = ::Partners::Stripe::PaymentIntents::Show.new(id: donation.stripe_payment_intent_id).run

        # 2. get remote available_on timestamp
        available_on = payment_intent.charges.data.first.balance_transaction.available_on

        # 3. create payout if time is ready. TODO: move this into the scope (by later moving the available_on into its own field on the donation table)
        ::PayoutService::Donation::Create.new(donation_id: donation.id).run if ready_for_payout?(available_on: available_on)
      end

      ::Invoice.paid.where("payout_id is null and payout_creation_balance_net is not null").each do |invoice|
        # 1. fetch remote invoice
        remote_invoice = ::Partners::Stripe::Invoices::Show.new(id: invoice.stripe_invoice_id).run

        charge = remote_invoice.charge

        next unless charge # only continue if a charge exists (invoice might have been paid via check)

        # 2. get remote available_on timestamp
        available_on = charge.balance_transaction.available_on

        # 3. create payout if time is ready. TODO: move this into the scope (by later moving available_on into its own field on the invoice table)
        ::PayoutService::Invoice::Create.new(invoice_id: invoice.id).run if ready_for_payout?(available_on: available_on)
      end
    end

    private

    def ready_for_payout?(available_on:)
      (Util.unixtime(available_on) + 1.days) < Time.now
    end
  end
end
