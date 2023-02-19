# frozen_string_literal: true

class CreateStripeAchPaymentSources < ActiveRecord::Migration[7.0]
  def change
    create_table :stripe_ach_payment_sources do |t|
      t.text :stripe_source_id
      t.text :stripe_customer_id
      t.text :account_number_ciphertext
      t.text :routing_number_ciphertext
      t.references :event, null: false, foreign_key: true

      t.index :stripe_source_id, unique: true

      t.timestamps
    end
  end

end
