# frozen_string_literal: true

class CreateAchPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :ach_payments do |t|
      t.text :stripe_source_transaction_id
      t.text :stripe_charge_id
      t.references :stripe_ach_payment_source, null: false, foreign_key: true

      t.timestamps
    end
  end

end
