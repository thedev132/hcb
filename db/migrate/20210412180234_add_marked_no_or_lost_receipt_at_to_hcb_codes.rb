# frozen_string_literal: true

class AddMarkedNoOrLostReceiptAtToHcbCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :hcb_codes, :marked_no_or_lost_receipt_at, :datetime
  end
end
