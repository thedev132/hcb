# frozen_string_literal: true

class AddStripePayoutIdToAchPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :ach_payments, :stripe_payout_id, :text
  end

end
