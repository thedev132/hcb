# frozen_string_literal: true

class AddPayoutIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :invoice_payout, foreign_key: true
  end
end
