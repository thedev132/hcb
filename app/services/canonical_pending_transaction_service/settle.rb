# frozen_string_literal: true

module CanonicalPendingTransactionService
  class Settle
    def initialize(canonical_transaction:, canonical_pending_transaction:)
      @canonical_transaction = canonical_transaction
      @canonical_pending_transaction = canonical_pending_transaction
    end

    def run!
      ActiveRecord::Base.transaction do
        CanonicalPendingSettledMapping.create!(
          canonical_transaction: @canonical_transaction,
          canonical_pending_transaction: @canonical_pending_transaction
        )

        if @canonical_transaction.custom_memo.nil?
          @canonical_transaction.custom_memo = @canonical_pending_transaction.custom_memo
          @canonical_transaction.save!
        end
      end
    end

  end
end
