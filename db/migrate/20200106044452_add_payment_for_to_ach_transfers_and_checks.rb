# frozen_string_literal: true

class AddPaymentForToAchTransfersAndChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :ach_transfers, :payment_for, :text
    add_column :checks, :payment_for, :text
  end
end
