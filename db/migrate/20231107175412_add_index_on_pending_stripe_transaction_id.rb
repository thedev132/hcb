# frozen_string_literal: true

class AddIndexOnPendingStripeTransactionId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :raw_pending_stripe_transactions, :stripe_transaction_id, unique: true, algorithm: :concurrently
  end

end
