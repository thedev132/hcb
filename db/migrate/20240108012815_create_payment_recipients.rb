# frozen_string_literal: true

class CreatePaymentRecipients < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_recipients do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.text :account_number_ciphertext
      t.string :routing_number_ciphertext
      t.string :bank_name_ciphertext

      t.timestamps
    end
  end

end
