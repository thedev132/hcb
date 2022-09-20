# frozen_string_literal: true

class AddReplacementForToStripeCards < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :stripe_cards, :replacement_for, null: true, index: { algorithm: :concurrently }
  end

end
