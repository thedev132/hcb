# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingDonationTransactionService
    module Donation
      class Import
        def initialize
        end

        def run
          pending_donation_transactions.each do |podt|
            ::PendingTransactionEngine::RawPendingDonationTransactionService::Donation::ImportSingle.new(donation: podt).run
          end

          nil
        end

        private

        def pending_donation_transactions
          @pending_donation_transactions ||= ::Donation.succeeded # TODO: deprecate succeeded
        end

      end
    end
  end
end
