# frozen_string_literal: true

class AddFrontedToCanonicalPendingTransaction < ActiveRecord::Migration[6.1]
  def change
    add_column :canonical_pending_transactions, :fronted, :boolean, default: false
  end

end
