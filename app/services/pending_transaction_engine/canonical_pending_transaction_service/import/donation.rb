# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class Donation
        def run
          raw_pending_donation_transactions_ready_for_processing.find_each(batch_size: 100) do |rpoct|
            ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Donation.new(raw_pending_donation_transaction: rpoct).run
          end
        end

        private

        def raw_pending_donation_transactions_ready_for_processing
          @raw_pending_donation_transactions_ready_for_processing ||= begin
            return RawPendingDonationTransaction.all if previously_processed_raw_pending_donation_transactions_ids.length < 1

            RawPendingDonationTransaction.where("id not in(?)", previously_processed_raw_pending_donation_transactions_ids)
          end
        end

        def previously_processed_raw_pending_donation_transactions_ids
          @previously_processed_raw_pending_donation_transactions_ids ||= ::CanonicalPendingTransaction.donation.pluck(:raw_pending_donation_transaction_id)
        end

      end
    end
  end
end
