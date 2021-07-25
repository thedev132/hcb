# frozen_string_literal: true

class AddStripeChargeIdToPartnerDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_donations, :stripe_charge_id, :string
  end
end
