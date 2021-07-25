# frozen_string_literal: true

class AddPayoutAmountToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :payout_creation_balance_net, :integer
  end
end
