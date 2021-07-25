# frozen_string_literal: true

class CreateAchTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :ach_transfers do |t|
      t.references :event, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }

      t.string :routing_number
      t.string :account_number
      t.string :bank_name
      t.string :recipient_name
      t.integer :amount
      t.datetime :approved_at

      t.timestamps
    end
  end
end
