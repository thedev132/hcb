# frozen_string_literal: true

class AddSubledgerToCanonicalEventMappings < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_event_mappings, :subledger, null: true, index: { algorithm: :concurrently }
    add_reference :canonical_pending_event_mappings, :subledger, null: true, index: { algorithm: :concurrently }
  end

end
