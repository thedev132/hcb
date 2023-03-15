# frozen_string_literal: true

class AddIncreaseTransactionToRawIncreaseTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :raw_increase_transactions, :increase_transaction, :jsonb
  end

end
