# frozen_string_literal: true

class AddIndexToRecurringDonationSubscriptionId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :recurring_donations, :stripe_subscription_id, unique: true, algorithm: :concurrently
  end

end
