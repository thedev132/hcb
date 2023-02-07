# frozen_string_literal: true

class AddStripeFieldsToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :stripe_customer_id, :text
    add_column :recurring_donations, :stripe_subscription_id, :text
    add_column :recurring_donations, :stripe_payment_intent_id, :text
    add_column :recurring_donations, :stripe_client_secret, :text
  end

end
