# frozen_string_literal: true

class AddProcessedAtToFeeReimbursements < ActiveRecord::Migration[5.2]
  def change
    add_column :fee_reimbursements, :processed_at, :datetime
  end
end
