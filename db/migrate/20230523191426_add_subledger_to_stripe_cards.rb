# frozen_string_literal: true

class AddSubledgerToStripeCards < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :stripe_cards, :subledger, null: true, index: { algorithm: :concurrently }
  end

end
