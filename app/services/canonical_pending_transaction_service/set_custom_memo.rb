# frozen_string_literal: true

module CanonicalPendingTransactionService
  class SetCustomMemo
    def initialize(canonical_pending_transaction_id:, custom_memo:)
      @canonical_pending_transaction_id = canonical_pending_transaction_id
      @custom_memo = custom_memo
    end

    def run
      canonical_pending_transaction.custom_memo = @custom_memo.blank? ? nil : @custom_memo.strip
      canonical_pending_transaction.save!
    end

    private

    def canonical_pending_transaction
      @canonical_pending_transaction ||= CanonicalPendingTransaction.find(@canonical_pending_transaction_id)
    end
  end
end
