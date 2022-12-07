# frozen_string_literal: true

module DisbursementService
  class Reject
    def initialize(disbursement_id:, fulfilled_by_id:)
      @disbursement = Disbursement.find disbursement_id
      @fulfilled_by = User.find fulfilled_by_id
    end

    def run
      raise ArgumentError, "Disbursement is already processed" unless @disbursement.reviewing?

      @disbursement.update!(attrs)
      @disbursement.mark_rejected!(@fulfilled_by)

      decline_pending_transactions!

      @disbursement
    end

    private

    def attrs
      {
        rejected_at: DateTime.now,
        fulfilled_by: @fulfilled_by
      }
    end

    def decline_pending_transactions!
      i_cpt = @disbursement&.raw_pending_incoming_disbursement_transaction&.canonical_pending_transaction
      o_cpt = @disbursement&.raw_pending_outgoing_disbursement_transaction&.canonical_pending_transaction

      ::PendingEventMappingEngine::Decline::Single::IncomingDisbursement.new(canonical_pending_transaction: i_cpt).run if i_cpt
      ::PendingEventMappingEngine::Decline::Single::OutgoingDisbursement.new(canonical_pending_transaction: o_cpt).run if o_cpt
    end

  end
end
