module EventMappingEngine
  module GuessEventId
    class Disbursement
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return unless disbursement

        if amount_cents > 0
          disbursement.event.id
        else
          disbursement.source_event.id
        end
      end

      private

      def disbursement
        @disbursement ||= ::Disbursement.find_by(id: disbursement_id)
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def memo
        @canonical_transaction.memo
      end

      def disbursement_id
        memo.gsub("HCB DISBURSE ", "").split(" ")[0]
      end
    end
  end
end
