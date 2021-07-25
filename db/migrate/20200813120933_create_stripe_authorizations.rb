# frozen_string_literal: true

class CreateStripeAuthorizations < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_authorizations do |t|
      t.text :stripe_id
      t.integer :stripe_status
      t.integer :authorization_method
      t.boolean :approved, null: false, default: false
      t.belongs_to :stripe_card, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
