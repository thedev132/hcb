class CreateHcbCodePins < ActiveRecord::Migration[7.0]
  def change
    create_table :hcb_code_pins do |t|
      t.references :hcb_code, foreign_key: true
      t.references :event, foreign_key: true
      t.timestamps
    end
  end
end
