class AddCreatorToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :creator, foreign_key: { to_table: :users }
  end
end
