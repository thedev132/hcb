# frozen_string_literal: true

class AddIndexToPaymentRecipientName < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :payment_recipients, :name, algorithm: :concurrently
  end

end
