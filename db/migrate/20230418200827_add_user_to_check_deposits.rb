# frozen_string_literal: true

class AddUserToCheckDeposits < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_reference :check_deposits, :created_by, null: false, index: { algorithm: :concurrently }
  end

end
