# frozen_string_literal: true

class CreateChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :checks do |t|
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.references :lob_address, index: true, foreign_key: true

      t.string :lob_id
      t.text :description
      t.text :memo
      t.integer :check_number
      t.integer :amount
      t.string :url
      t.datetime :expected_delivery_date
      t.datetime :send_date
      t.string :transaction_memo
      t.datetime :voided_at
      t.datetime :approved_at
      t.datetime :exported_at
      t.datetime :refunded_at

      t.timestamps
    end
  end
end
