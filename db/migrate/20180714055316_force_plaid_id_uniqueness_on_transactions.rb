# frozen_string_literal: true

class ForcePlaidIdUniquenessOnTransactions < ActiveRecord::Migration[5.2]
  def change
    add_index :transactions, :plaid_id, unique: true
  end
end
