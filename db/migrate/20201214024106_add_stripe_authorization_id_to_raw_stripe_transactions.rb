class AddStripeAuthorizationIdToRawStripeTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_stripe_transactions, :stripe_authorization_id, :text
  end
end
