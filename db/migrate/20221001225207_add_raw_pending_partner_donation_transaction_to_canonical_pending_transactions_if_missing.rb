# frozen_string_literal: true

class AddRawPendingPartnerDonationTransactionToCanonicalPendingTransactionsIfMissing < ActiveRecord::Migration[6.1]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:canonical_pending_transactions, :raw_pending_partner_donation_transaction_id)
      add_column :canonical_pending_transactions, :raw_pending_partner_donation_transaction_id, :bigint
    end
  end

end
