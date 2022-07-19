# frozen_string_literal: true

class ValidateMakeFrontedRequiredOnCanonicalPendingTransactions < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :canonical_pending_transactions, name: "canonical_pending_transactions_fronted_null"
  end

end
