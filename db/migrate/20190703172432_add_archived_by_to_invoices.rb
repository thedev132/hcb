class AddArchivedByToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :archived_by, foreign_key: {to_table: :users}
  end
end
