class CreateBankFees < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_fees do |t|
      t.references :event, null: false, foreign_key: true
      t.string :hcb_code
      t.string :aasm_state
      t.integer :amount_cents

      t.timestamps
    end
  end
end
