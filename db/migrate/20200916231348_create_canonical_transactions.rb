# frozen_string_literal: true

class CreateCanonicalTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_transactions do |t|
      t.date :date, null: false
      t.text :memo, null: false
      t.integer :amount_cents, null: false

      t.timestamps
    end
  end
end
