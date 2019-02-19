class AddFinalizedAtToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :finalized_at, :datetime
  end
end
