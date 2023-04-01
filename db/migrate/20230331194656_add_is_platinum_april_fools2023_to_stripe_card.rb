# frozen_string_literal: true

class AddIsPlatinumAprilFools2023ToStripeCard < ActiveRecord::Migration[7.0]
  def change
    add_column :stripe_cards, :is_platinum_april_fools_2023, :boolean
  end

end
