# frozen_string_literal: true

class AddConfirmationNumberToAchTransfers < ActiveRecord::Migration[6.0]
  def change
    add_column :ach_transfers, :confirmation_number, :text
  end
end
