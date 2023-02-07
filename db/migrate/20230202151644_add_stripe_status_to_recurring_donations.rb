# frozen_string_literal: true

class AddStripeStatusToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :stripe_status, :text
  end

end
