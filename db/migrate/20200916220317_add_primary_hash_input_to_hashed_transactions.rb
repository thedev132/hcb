# frozen_string_literal: true

class AddPrimaryHashInputToHashedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :hashed_transactions, :primary_hash_input, :text
  end
end
