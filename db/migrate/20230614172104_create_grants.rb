# frozen_string_literal: true

class CreateGrants < ActiveRecord::Migration[7.0]
  def change
    create_table :grants do |t|
      t.integer :amount_cents
      t.references :event, null: false, foreign_key: true
      t.string :aasm_state
      t.text :reason
      t.references :processed_by, null: true, foreign_key: { to_table: :users }
      t.references :submitted_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end

end
