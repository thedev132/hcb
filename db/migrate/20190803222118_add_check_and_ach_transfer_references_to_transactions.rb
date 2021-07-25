# frozen_string_literal: true

class AddCheckAndAchTransferReferencesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :check, foreign_key: true
    add_reference :transactions, :ach_transfer, foreign_key: true
  end
end
