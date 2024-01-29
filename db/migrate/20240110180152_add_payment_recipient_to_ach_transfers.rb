# frozen_string_literal: true

class AddPaymentRecipientToAchTransfers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :ach_transfers, :payment_recipient, null: true, index: { algorithm: :concurrently }
  end

end
