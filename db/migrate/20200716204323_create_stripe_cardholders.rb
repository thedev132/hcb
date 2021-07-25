# frozen_string_literal: true

class CreateStripeCardholders < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_cardholders, if_not_exists: true do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.text :stripe_id
      t.text :stripe_billing_address_line1
      t.text :stripe_billing_address_line2
      t.text :stripe_billing_address_city
      t.text :stripe_billing_address_country
      t.text :stripe_billing_address_postal_code
      t.text :stripe_billing_address_state
      t.text :stripe_name
      t.text :stripe_email
      t.text :stripe_phone_number
      t.integer :cardholder_type, null: false, default: 0

      t.timestamps
    end
  end
end
