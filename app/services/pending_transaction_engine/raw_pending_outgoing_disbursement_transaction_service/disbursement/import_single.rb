# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingDisbursementTransactionService
    module Disbursement
      class ImportSingle
        def initialize(disbursement:)
          @disbursement = disbursement
        end

        def run
          ::RawPendingOutgoingDisbursementTransaction.find_or_create_by(attrs)
        end

        private

        def attrs
          {
            disbursement_id: @disbursement.id,
            amount_cents: -@disbursement.amount.abs,
            date_posted: @disbursement.in_transit_at || @disbursement.created_at
          }
        end

      end
    end
  end
end
