# frozen_string_literal: true

class MakeFrontedRequiredOnCanonicalPendingTransactions < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :canonical_pending_transactions, "fronted IS NOT NULL", name: "canonical_pending_transactions_fronted_null", validate: false
  end

end
