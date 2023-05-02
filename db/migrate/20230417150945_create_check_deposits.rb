# frozen_string_literal: true

class CreateCheckDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :check_deposits do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :amount_cents

      t.timestamps
    end
  end

end
