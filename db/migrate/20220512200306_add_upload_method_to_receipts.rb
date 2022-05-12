# frozen_string_literal: true

class AddUploadMethodToReceipts < ActiveRecord::Migration[6.0]
  def change
    add_column :receipts, :upload_method, :int
  end

end
