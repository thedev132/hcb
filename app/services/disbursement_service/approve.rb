# frozen_string_literal: true

module DisbursementService
  class Approve
    def initialize(disbursement_id:, fulfilled_by_id:)
      @disbursement = Disbursement.find disbursement_id
      @fulfilled_by = User.find fulfilled_by_id
    end

    def run
      raise ArgumentError, "Disbursement is already processed" unless @disbursement.reviewing?

      ActiveRecord::Base.transaction do
        # 1. Approve the disbursement
        @disbursement.mark_approved!(@fulfilled_by)

        # 2. Create the raw pending transactions
        rpidt = ::PendingTransactionEngine::RawPendingIncomingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement: @disbursement).run
        rpodt = ::PendingTransactionEngine::RawPendingOutgoingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement: @disbursement).run

        # 3. Canonize the newly added raw pending transactions
        i_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::IncomingDisbursement.new(raw_pending_incoming_disbursement_transaction: rpidt).run
        o_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingDisbursement.new(raw_pending_outgoing_disbursement_transaction: rpodt).run

        # 4. Map to event
        ::PendingEventMappingEngine::Map::Single::IncomingDisbursement.new(canonical_pending_transaction: i_cpt).run
        ::PendingEventMappingEngine::Map::Single::OutgoingDisbursement.new(canonical_pending_transaction: o_cpt).run
      end

      @disbursement
    end

  end
end
