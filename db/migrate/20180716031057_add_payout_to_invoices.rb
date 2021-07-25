# frozen_string_literal: true

class AddPayoutToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :payout, foreign_key: { to_table: :invoice_payouts }
  end
end
