# frozen_string_literal: true

class RemoveAttemptedMatchAtFromReceipts < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :receipts, :attempted_match_at }
  end

end
