# frozen_string_literal: true

class CreateRawColumnTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :raw_column_transactions do |t|
      t.string :column_report_id
      t.integer :transaction_index
      t.jsonb :column_transaction
      t.text :description
      t.date :date_posted
      t.integer :amount_cents

      t.timestamps
    end
  end

end
