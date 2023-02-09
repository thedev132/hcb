# frozen_string_literal: true

class AddCanonicalPendingTransactionIndexToCanonicalPendingDeclinedMapping < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :canonical_pending_declined_mappings, :canonical_pending_transaction_id, unique: true, name: "index_canonical_pending_declined_mappings_on_cpt_id", algorithm: :concurrently
    remove_index :canonical_pending_declined_mappings, name: :index_canonical_pending_declined_map_on_canonical_pending_tx_id
  end

end
