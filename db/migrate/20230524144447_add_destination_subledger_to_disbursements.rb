# frozen_string_literal: true

class AddDestinationSubledgerToDisbursements < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :disbursements, :destination_subledger, null: true, index: { algorithm: :concurrently }
  end

end
