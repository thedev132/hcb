# frozen_string_literal: true

class AddMigratedFromLegacyStripeAccountToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :migrated_from_legacy_stripe_account, :boolean, default: false
  end

end
