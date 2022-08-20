# frozen_string_literal: true

class AddApiKeyCiphertextToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :api_key_ciphertext, :text
  end

end
