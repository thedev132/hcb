module PendingTransactionEngine
  module RawPendingDonationTransactionService
    module Donation
      class Import
        def initialize
        end

        def run
          pending_donation_transactions.each do |podt|
            ::RawPendingDonationTransaction.find_or_initialize_by(donation_transaction_id: podt.id.to_s).tap do |t|
              t.amount_cents = podt.amount
              t.date_posted = podt.created_at
            end.save!
          end

          nil
        end

        private

        def pending_donation_transactions
          @pending_donation_transactions ||= ::Donation.succeeded
        end
      end
    end
  end
end
