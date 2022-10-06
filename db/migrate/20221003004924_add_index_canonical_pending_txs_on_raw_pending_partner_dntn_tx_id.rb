# frozen_string_literal: true

class AddIndexCanonicalPendingTxsOnRawPendingPartnerDntnTxId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :canonical_pending_transactions, :raw_pending_partner_donation_transaction_id, name: :index_canonical_pending_txs_on_raw_pending_partner_dntn_tx_id, if_exists: true
    add_index :canonical_pending_transactions, :raw_pending_partner_donation_transaction_id, name: :index_canonical_pending_txs_on_raw_pending_partner_dntn_tx_id, algorithm: :concurrently
  end

end
