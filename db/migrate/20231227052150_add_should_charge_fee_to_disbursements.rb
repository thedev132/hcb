# frozen_string_literal: true

class AddShouldChargeFeeToDisbursements < ActiveRecord::Migration[7.0]
  def change
    add_column :disbursements, :should_charge_fee, :boolean, default: false
  end

end
