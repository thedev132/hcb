# frozen_string_literal: true

class CreateCardGrants < ActiveRecord::Migration[7.0]
  def change
    create_table :card_grants do |t|
      t.integer :amount_cents
      t.references :event, null: false, foreign_key: true
      t.references :subledger, null: false, foreign_key: true
      t.references :stripe_card, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :sent_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end

end
