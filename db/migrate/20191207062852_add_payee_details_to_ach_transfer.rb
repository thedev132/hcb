# frozen_string_literal: true

class AddPayeeDetailsToAchTransfer < ActiveRecord::Migration[5.2]
  def change
    add_column :ach_transfers, :recipient_tel, :string
  end
end
