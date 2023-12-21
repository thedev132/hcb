# frozen_string_literal: true

class CreateColumnAccountNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :column_account_numbers do |t|
      t.text :account_number_ciphertext
      t.text :routing_number_ciphertext
      t.text :bic_code_ciphertext
      t.text :column_id
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end

end
