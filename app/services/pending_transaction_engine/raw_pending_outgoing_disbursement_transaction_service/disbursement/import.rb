# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingDisbursementTransactionService
    module Disbursement
      class Import
        def run
          disbursements.each do |disbursement|
            ImportSingle.new(disbursement: disbursement).run
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
