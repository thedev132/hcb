# frozen_string_literal: true

class AddStripeCardShippingTypeToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :stripe_card_shipping_type, :integer, default: 0, null: false
  end

end
