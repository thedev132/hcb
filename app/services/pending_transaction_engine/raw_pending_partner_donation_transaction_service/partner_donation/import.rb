# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingPartnerDonationTransactionService
    module PartnerDonation
      class Import
        def initialize
        end

        def run
          pending_partner_donation.find_each(batch_size: 100) do |pdn|
            ::RawPendingPartnerDonationTransaction.find_or_initialize_by(partner_donation_transaction_id: pdn.id.to_s).tap do |rppdt|
              rppdt.amount_cents = pdn.payout_amount_cents
              rppdt.date_posted = pdn.created_at
            end.save!
          end

          nil
        end

        private

        def pending_partner_donation
          @pending_partner_donation ||= ::PartnerDonation.pending
        end

      end
    end
  end
end
