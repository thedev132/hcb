# frozen_string_literal: true

class AddFeeRevenueToBankFee < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :bank_fees, :fee_revenue, null: true, index: { algorithm: :concurrently }
  end

end
