module PendingEventMappingEngine
  module Settle
    class BankFeeHcbCode
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 2. identify ct
          ct = cpt.local_hcb_code.canonical_transactions.first

          if ct
            # 3. mark no longer pending
            attrs = {
              canonical_transaction_id: ct.id,
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingSettledMapping.create!(attrs)
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.bank_fee
      end
    end
  end
end
