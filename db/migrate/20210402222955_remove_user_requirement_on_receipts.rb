# frozen_string_literal: true

class RemoveUserRequirementOnReceipts < ActiveRecord::Migration[6.0]
  def change
    change_column_null :receipts, :user_id, true
  end
end
