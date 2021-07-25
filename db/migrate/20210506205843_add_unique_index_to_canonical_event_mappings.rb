# frozen_string_literal: true

class AddUniqueIndexToCanonicalEventMappings < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :canonical_event_mappings, [:event_id, :canonical_transaction_id], unique: true, name: "index_cem_event_id_canonical_transaction_id_uniqueness"
    end
  end
end
