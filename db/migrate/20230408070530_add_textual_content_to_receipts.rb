# frozen_string_literal: true

class AddTextualContentToReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :receipts, :textual_content_ciphertext, :text
  end

end
