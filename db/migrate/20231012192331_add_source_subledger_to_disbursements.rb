# frozen_string_literal: true

class AddSourceSubledgerToDisbursements < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :disbursements, :source_subledger, null: true, index: { algorithm: :concurrently }
  end

end
