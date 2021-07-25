# frozen_string_literal: true

class CreateCanonicalPendingSettledMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_pending_settled_mappings do |t|
      t.references :canonical_pending_transaction, null: false, foreign_key: true, index: { name: :index_canonical_pending_settled_map_on_canonical_pending_tx_id }
      t.references :canonical_transaction, null: false, foreign_key: true, index: { name: :index_canonical_pending_settled_mappings_on_canonical_tx_id }

      t.timestamps
    end
  end
end
