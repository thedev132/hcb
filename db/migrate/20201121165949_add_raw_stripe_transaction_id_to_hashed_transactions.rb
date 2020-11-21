class AddRawStripeTransactionIdToHashedTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :hashed_transactions, :raw_stripe_transaction, index: {algorithm: :concurrently}
  end
end
