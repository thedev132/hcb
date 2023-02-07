# frozen_string_literal: true

class AddStripeCurrentPeriodEndToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :stripe_current_period_end, :datetime
  end

end
