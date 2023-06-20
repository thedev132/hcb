# frozen_string_literal: true

class AddIndexOnRawPendingStripeTransactionCardholderId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :raw_pending_stripe_transactions, "(stripe_transaction->'card'->'cardholder'->>'id')", name: "index_raw_pending_stripe_transactions_on_cardholder_id", algorithm: :concurrently
  end

end
