# frozen_string_literal: true

class AddRecipientToGrants < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :grants, :recipient, null: false, index: { algorithm: :concurrently }
  end

end
