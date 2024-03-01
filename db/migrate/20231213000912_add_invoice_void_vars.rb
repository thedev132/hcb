# frozen_string_literal: true

class AddInvoiceVoidVars < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :invoices, :voided_by,
                    null: true,
                    foreign_key: { to_table: :users },
                    index: { algorithm: :concurrently }
      add_column :invoices, :void_v2_at, :datetime
    end
  end

end
