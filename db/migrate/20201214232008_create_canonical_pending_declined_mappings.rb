class CreateCanonicalPendingDeclinedMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_pending_declined_mappings do |t|
      t.references :canonical_pending_transaction, null: false, foreign_key: true, index: { name: :index_canonical_pending_declined_map_on_canonical_pending_tx_id }

      t.timestamps
    end
  end
end
