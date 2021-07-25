# frozen_string_literal: true

class CreateFeeReimbursements < ActiveRecord::Migration[5.2]
  def change
    create_table :fee_reimbursements do |t|
      t.bigint :amount
      t.string :transaction_memo

      t.timestamps
    end
  end
end
