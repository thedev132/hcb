# frozen_string_literal: true

class AddActivatedToStripeCard < ActiveRecord::Migration[6.1]
  def change
    add_column :stripe_cards, :activated, :boolean, default: true # set to true for existing cards
    change_column_default :stripe_cards, :activated, false # default to false for new cards

  end

end
