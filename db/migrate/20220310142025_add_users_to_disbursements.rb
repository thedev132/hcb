# frozen_string_literal: true

class AddUsersToDisbursements < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :disbursements, :requested_by,
                    null: true,
                    foreign_key: { to_table: :users },
                    index: { algorithm: :concurrently }
      add_reference :disbursements, :fulfilled_by,
                    null: true,
                    foreign_key: { to_table: :users },
                    index: { algorithm: :concurrently }
    end
  end

end
