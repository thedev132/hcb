# frozen_string_literal: true

class AddFeeReimbursementReferencesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :fee_reimbursement, foreign_key: true
  end
end
