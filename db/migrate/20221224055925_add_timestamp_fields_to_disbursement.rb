# frozen_string_literal: true

class AddTimestampFieldsToDisbursement < ActiveRecord::Migration[6.1]
  def change
    add_column :disbursements, :pending_at, :datetime
    add_column :disbursements, :in_transit_at, :datetime
    add_column :disbursements, :deposited_at, :datetime
  end

end
