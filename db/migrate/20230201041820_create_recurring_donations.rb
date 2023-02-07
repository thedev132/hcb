# frozen_string_literal: true

class CreateRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    create_table :recurring_donations do |t|
      t.text :email
      t.text :name
      t.references :event, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end

end
