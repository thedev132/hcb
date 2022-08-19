# frozen_string_literal: true

class DropAccountNumberFromAchTransfers < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :ach_transfers, :account_number
    end
  end

end
