# frozen_string_literal: true

class AddHcbCodeToCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :canonical_pending_transactions, :hcb_code, :text
  end
end
