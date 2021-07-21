module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class PartnerDonation
        def run
          raw_pending_partner_donation_transactions_ready_for_processing.find_each(batch_size: 100) do |rpit|

            ActiveRecord::Base.transaction do
              attrs = {
                date: rpit.date,
                memo: rpit.memo,
                amount_cents: rpit.amount_cents,
                raw_pending_partner_donation_transaction_id: rpit.id
              }
              ct = ::CanonicalPendingTransaction.create!(attrs)
            end

          end
        end

        private

        def raw_pending_partner_donation_transactions_ready_for_processing
          @raw_pending_partner_donation_transactions_ready_for_processing ||= begin
            return RawPendingPartnerDonationTransaction.all if previously_processed_raw_pending_partner_donation_transactions_ids.length < 1

            RawPendingPartnerDonationTransaction.where('id not in(?)', previously_processed_raw_pending_partner_donation_transactions_ids)
          end
        end

        def previously_processed_raw_pending_partner_donation_transactions_ids
          @previously_processed_raw_pending_partner_donation_transactions_ids ||= ::CanonicalPendingTransaction.partner_donation.pluck(:raw_pending_partner_donation_transaction_id)
        end
      end
    end
  end
end
