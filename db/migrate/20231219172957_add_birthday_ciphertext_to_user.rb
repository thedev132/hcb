# frozen_string_literal: true

class AddBirthdayCiphertextToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :birthday_ciphertext, :text
  end

end
