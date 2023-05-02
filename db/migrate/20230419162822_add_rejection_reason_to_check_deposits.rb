# frozen_string_literal: true

class AddRejectionReasonToCheckDeposits < ActiveRecord::Migration[7.0]
  def change
    add_column :check_deposits, :rejection_reason, :string
  end

end
