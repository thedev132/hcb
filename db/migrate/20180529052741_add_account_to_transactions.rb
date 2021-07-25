# frozen_string_literal: true

class AddAccountToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :bank_account, foreign_key: true
  end
end
