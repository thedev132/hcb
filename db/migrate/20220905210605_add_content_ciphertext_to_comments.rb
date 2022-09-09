# frozen_string_literal: true

class AddContentCiphertextToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :content_ciphertext, :text
  end

end
