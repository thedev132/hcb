# frozen_string_literal: true

class AddAccountNumberCiphertextToAchTransfers < ActiveRecord::Migration[6.1]
  def change
    add_column :ach_transfers, :account_number_ciphertext, :text
  end

end
