# frozen_string_literal: true

class CreateLobAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :lob_addresses do |t|
      t.references :event, index: true, foreign_key: true

      t.text :description
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :lob_id

      t.timestamps
    end
  end
end
