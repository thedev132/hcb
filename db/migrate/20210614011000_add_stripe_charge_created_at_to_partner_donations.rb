class AddStripeChargeCreatedAtToPartnerDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_donations, :stripe_charge_created_at, :datetime
  end
end