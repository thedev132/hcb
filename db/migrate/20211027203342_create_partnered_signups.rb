# frozen_string_literal: true

class CreatePartneredSignups < ActiveRecord::Migration[6.0]
  def change
    create_table :partnered_signups do |t|
      t.string :owner_phone
      t.string :owner_email
      t.string :owner_name
      t.string :owner_address
      t.string :redirect_url, null: false
      t.date :owner_birthdate
      t.integer :country
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
