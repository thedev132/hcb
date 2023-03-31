# frozen_string_literal: true

class CreateIncreaseChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :increase_checks do |t|
      t.string :memo
      t.string :payment_for
      t.integer :amount
      t.string :address_city
      t.string :address_line1
      t.string :address_line2
      t.string :address_state
      t.string :address_zip
      t.string :recipient_name
      t.string :increase_id
      t.string :aasm_state
      t.string :increase_state
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end

end
