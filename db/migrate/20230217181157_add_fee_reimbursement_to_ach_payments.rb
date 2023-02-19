# frozen_string_literal: true

class AddFeeReimbursementToAchPayments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :ach_payments, :fee_reimbursement, null: true, index: { algorithm: :concurrently }
  end

end
