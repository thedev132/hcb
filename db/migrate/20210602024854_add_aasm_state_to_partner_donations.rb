# frozen_string_literal: true

class AddAasmStateToPartnerDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_donations, :aasm_state, :string
    add_column :partner_donations, :payout_amount_cents, :integer
  end
end
