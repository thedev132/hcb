# frozen_string_literal: true

class AddRejectedAtToAchTransfer < ActiveRecord::Migration[5.2]
  def change
    add_column :ach_transfers, :rejected_at, :datetime
  end
end
