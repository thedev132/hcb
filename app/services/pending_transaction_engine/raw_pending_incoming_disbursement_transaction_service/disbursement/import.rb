# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingIncomingDisbursementTransactionService
    module Disbursement
      class Import
        def run
          disbursements.each do |disbursement|
            ImportSingle.new(disbursement: disbursement).run
          end
        end

        private

        def disbursements
          ::Disbursement.where.not(fulfilled_by: nil).where.not(fulfilled_at: nil).where.missing :raw_pending_incoming_disbursement_transaction
        end

      end
    end
  end
end
