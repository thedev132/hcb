class CreateHcbCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :hcb_codes do |t|
      t.text :hcb_code, unique: true, null: false

      t.timestamps
    end
  end
end
