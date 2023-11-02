# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingDisbursementTransactionService
    module Disbursement
      class Import
        def run
          disbursements.find_each(batch_size: 100) do |disbursement|
            ImportSingle.new(disbursement:).run
          end
        end

        private

        def disbursements
          ::Disbursement.where.missing :raw_pending_outgoing_disbursement_transaction
        end

      end
    end
  end
end
