# frozen_string_literal: true

class CreateStripeCards < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_cards, if_not_exists: true do |t|
      t.belongs_to :event, null: false, foreign_key: true
      t.belongs_to :stripe_cardholder, null: false, foreign_key: true

      t.text :stripe_id
      t.text :stripe_brand
      t.integer :stripe_exp_month
      t.integer :stripe_exp_year
      t.text :last4
      t.integer :card_type, null: false, default: 0
      t.text :stripe_status

      t.text :stripe_shipping_address_city
      t.text :stripe_shipping_address_country
      t.text :stripe_shipping_address_line1
      t.text :stripe_shipping_address_postal_code
      t.text :stripe_shipping_address_line2
      t.text :stripe_shipping_address_state
      t.text :stripe_shipping_name

      t.timestamps
    end
  end
end
