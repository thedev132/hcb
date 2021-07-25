# frozen_string_literal: true

class CreateRawCsvTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_csv_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.text :memo
      t.jsonb :raw_data

      t.timestamps
    end
  end
end
