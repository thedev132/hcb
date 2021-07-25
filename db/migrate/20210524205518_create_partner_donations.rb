# frozen_string_literal: true

class CreatePartnerDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_donations do |t|
      t.references :event, null: false, foreign_key: true
      t.string :hcb_code, unique: true, null: false
      t.string :donation_identifier, unique: true, null: false

      t.timestamps
    end
  end
end
