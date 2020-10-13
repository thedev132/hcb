class CreateCanonicalEventMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_event_mappings do |t|
      t.references :canonical_transaction, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
