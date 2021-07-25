# frozen_string_literal: true

class AddPayoutFeeToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payout_creation_balance_stripe_fee, :integer
  end
end
