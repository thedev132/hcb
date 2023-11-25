# frozen_string_literal: true

class AddIndexToStripeCardStripeId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :stripe_cards, :stripe_id, unique: true, algorithm: :concurrently
  end

end
