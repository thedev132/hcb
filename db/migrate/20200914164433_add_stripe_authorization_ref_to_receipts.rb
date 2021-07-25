# frozen_string_literal: true

class AddStripeAuthorizationRefToReceipts < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_reference :receipts, :stripe_authorization, foreign_key: true
    end
  end
end
