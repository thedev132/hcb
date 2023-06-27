# frozen_string_literal: true

class AddReceiptMethodToGrants < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :grants, :receipt_method, :integer
    add_reference :grants, :disbursement, null: true, index: { algorithm: :concurrently }
    add_reference :grants, :ach_transfer, null: true, index: { algorithm: :concurrently }
    add_reference :grants, :increase_check, null: true, index: { algorithm: :concurrently }

  end

end
