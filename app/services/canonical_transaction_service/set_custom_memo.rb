module CanonicalTransactionService
  class SetCustomMemo
    def initialize(canonical_transaction_id:, custom_memo:)
      @canonical_transaction_id = canonical_transaction_id
      @custom_memo = custom_memo
    end

    def run
      canonical_transaction.custom_memo = @custom_memo.blank? ? nil : @custom_memo.upcase.strip
      canonical_transaction.save!
    end

    private

    def canonical_transaction
      @canonical_transaction ||= CanonicalTransaction.find(@canonical_transaction_id)
    end
  end
end
