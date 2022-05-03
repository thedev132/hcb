# frozen_string_literal: true

class AddStripeIdIndexToStripeCardholders < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :stripe_cardholders, :stripe_id, algorithm: :concurrently
  end

end
