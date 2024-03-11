class CreateUserPayoutMethodChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_payout_method_checks do |t|
      t.text :address_line1, null: false
      t.text :address_line2
      t.text :address_city, null: false
      t.text :address_country, null: false
      t.text :address_postal_code, null: false
      t.text :address_state, null: false
      t.timestamps
    end
    add_column :users, :payout_method_type, :string
    add_column :users, :payout_method_id, :bigint
  end
end
