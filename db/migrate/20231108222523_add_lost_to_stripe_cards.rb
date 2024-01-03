# frozen_string_literal: true

class AddLostToStripeCards < ActiveRecord::Migration[7.0]
  def change
    add_column :stripe_cards, :lost_in_shipping, :boolean, default: false
  end

end
