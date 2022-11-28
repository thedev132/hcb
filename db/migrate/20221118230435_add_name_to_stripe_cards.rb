# frozen_string_literal: true

class AddNameToStripeCards < ActiveRecord::Migration[6.1]
  def change
    add_column :stripe_cards, :name, :string
  end

end
