# frozen_string_literal: true

class CreateTransactionCsvs < ActiveRecord::Migration[6.0]
  def change
    create_table :transaction_csvs do |t|
      t.string :aasm_state
      t.timestamps
    end
  end
end
