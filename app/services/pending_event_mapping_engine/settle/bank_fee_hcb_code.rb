# frozen_string_literal: true

module PendingEventMappingEngine
  module Settle
    class BankFeeHcbCode
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 2. identify ct
          ct = cpt.local_hcb_code.canonical_transactions.first

          if ct
            # 3. mark no longer pending
            CanonicalPendingTransactionService::Settle.new(
              canonical_transaction: ct,
              canonical_pending_transaction: cpt
            ).run!
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
