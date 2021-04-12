class AddHcbCodeToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :hcb_code, :text
  end
end
