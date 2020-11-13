class AddNoOrLostReceiptToReceiptable < ActiveRecord::Migration[6.0]
  def change
    add_column :stripe_authorizations, :marked_no_or_lost_receipt_at, :datetime
    add_column :emburse_transactions, :marked_no_or_lost_receipt_at, :datetime
  end
end
