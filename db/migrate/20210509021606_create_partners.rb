class CreatePartners < ActiveRecord::Migration[6.0]
  def change
    create_table :partners do |t|
      t.string :slug, unique: true, null: false
      t.text :api_key

      t.timestamps
    end
  end
end
