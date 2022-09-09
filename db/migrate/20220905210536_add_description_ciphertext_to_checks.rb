# frozen_string_literal: true

class AddDescriptionCiphertextToChecks < ActiveRecord::Migration[6.1]
  def change
    add_column :checks, :description_ciphertext, :text
  end

end
