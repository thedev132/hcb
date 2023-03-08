# frozen_string_literal: true

class AddIndexOnRawPendingStripeTransactionJsonbCardId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :raw_pending_stripe_transactions, "((stripe_transaction->'card'->>'id')::text)", name: :index_raw_pending_stripe_transactions_on_card_id_text, using: "hash", algorithm: :concurrently
  end

  def down
    remove_index :raw_pending_stripe_transactions, name: :index_raw_pending_stripe_transactions_on_card_id_text
  end

end
