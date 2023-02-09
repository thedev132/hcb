# frozen_string_literal: true

class AddFeeWaivedToCanonicalPendingTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :canonical_pending_transactions, :fee_waived, :boolean, default: false
  end

end
