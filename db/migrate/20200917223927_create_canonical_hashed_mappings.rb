# frozen_string_literal: true

class CreateCanonicalHashedMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_hashed_mappings do |t|
      t.references :canonical_transaction, null: false, foreign_key: true
      t.references :hashed_transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
