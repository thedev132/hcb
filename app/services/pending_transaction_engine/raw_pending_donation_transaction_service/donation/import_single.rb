# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingDonationTransactionService
    module Donation
      class ImportSingle
        def initialize(donation:)
          @donation = donation
        end

        def run
          rpdt = ::RawPendingDonationTransaction.find_or_initialize_by(donation_transaction_id: @donation.id.to_s).tap do |t|
            t.amount_cents = @donation.amount
            t.date_posted = @donation.created_at
          end

          rpdt.save!

          rpdt
        end

      end
    end
  end
end
