# frozen_string_literal: true

class CreateIncreaseAccountNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :increase_account_numbers do |t|
      t.text :account_number_ciphertext
      t.text :routing_number_ciphertext
      t.references :event, null: false, foreign_key: true
      t.string :increase_account_number_id
      t.string :increase_limit_id

      t.timestamps
    end
  end

end
