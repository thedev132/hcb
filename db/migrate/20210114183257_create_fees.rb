# frozen_string_literal: true

class CreateFees < ActiveRecord::Migration[6.0]
  def change
    create_table :fees do |t|
      t.references :canonical_event_mapping, null: false, foreign_key: true

      t.decimal :amount_cents_as_decimal
      t.decimal :event_sponsorship_fee
      t.text :reason

      t.timestamps
    end
  end
end
