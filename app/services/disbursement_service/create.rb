# frozen_string_literal: true

module DisbursementService
  class Create
    include ::Shared::AmpleBalance

    def initialize(source_event_id:, destination_event_id:,
                   name:, amount:, requested_by_id:, fulfilled_by_id: nil, destination_subledger_id: nil)
      @source_event_id = source_event_id
      @source_event = Event.friendly.find(@source_event_id)
      @destination_event_id = destination_event_id
      @destination_event = Event.friendly.find(@destination_event_id)
      @destination_subledger_id = destination_subledger_id
      @name = name
      @amount = amount
      @requested_by_id = requested_by_id
      @fulfilled_by_id = fulfilled_by_id
    end

    def run
      raise ArgumentError, "amount is required" unless @amount
      raise ArgumentError, "amount_cents must be greater than 0" unless amount_cents > 0
      raise ArgumentError, "You don't have enough money to make this disbursement." unless ample_balance?(amount_cents, @source_event) || requested_by.admin?

      disbursement = Disbursement.create!(attrs)

      # 1. Create the raw pending transactions
      rpidt = ::PendingTransactionEngine::RawPendingIncomingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement:).run
      rpodt = ::PendingTransactionEngine::RawPendingOutgoingDisbursementTransactionService::Disbursement::ImportSingle.new(disbursement:).run

      # 2. Canonize the newly added raw pending transactions
      i_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::IncomingDisbursement.new(raw_pending_incoming_disbursement_transaction: rpidt).run
      o_cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingDisbursement.new(raw_pending_outgoing_disbursement_transaction: rpodt).run

      # 3. Map to event
      ::PendingEventMappingEngine::Map::Single::IncomingDisbursement.new(canonical_pending_transaction: i_cpt).run
      ::PendingEventMappingEngine::Map::Single::OutgoingDisbursement.new(canonical_pending_transaction: o_cpt).run

      if requested_by&.admin? || disbursement.source_event == disbursement.destination_event # Auto-fulfill disbursements between subledgers in the same event
        disbursement.mark_approved!(requested_by)
      end

      disbursement
    end

    private

    def attrs
      {
        source_event_id: source_event.id,
        event_id: destination_event.id,
        destination_subledger_id: @destination_subledger_id,
        name: @name,
        amount: amount_cents,
        requested_by:,
      }
    end

    def requested_by
      @requested_by ||= User.find @requested_by_id if @requested_by_id
    end

    def amount_cents
      Monetize.parse(@amount).cents
    end

    def source_event
      @source_event ||= Event.find(@source_event_id)
    end

    def destination_event
      @destination_event ||= Event.find(@destination_event_id)
    end

  end
end
