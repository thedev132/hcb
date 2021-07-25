# frozen_string_literal: true

class CreateSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsors do |t|
      t.references :event, foreign_key: true
      t.text :name
      t.text :contact_email
      t.text :address_line1
      t.text :address_line2
      t.text :address_city
      t.text :address_state
      t.text :address_postal_code
      t.text :stripe_customer_id

      t.timestamps
    end
  end
end
