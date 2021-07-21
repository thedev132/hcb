module PendingTransactionEngine
  module RawPendingPartnerDonationTransactionService
    module PartnerDonation
      class Import
        def initialize
        end

        def run
          in_transit_partner_donation_transactions.find_each(batch_size: 100) do |pdt|
            ::RawPendingPartnerDonationTransaction.find_or_initialize_by(partner_donation_transaction_id: pdt.id.to_s).tap do |t|
              t.amount_cents = pdt.payout_amount_cents
              t.date_posted = pdt.created_at
            end.save!
          end

          nil
        end

        private

        def in_transit_partner_donation_transactions
          @in_transit_partner_donation_transactions ||= ::PartnerDonation.in_transit
        end
      end
    end
  end
end
