class CreatePartnerDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_donations do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :hcb_code

      t.timestamps
    end
  end
end
