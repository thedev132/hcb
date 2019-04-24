class AddReimburseableAndFeeReimbursementReferencesToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :reimbursable, :boolean
    add_reference :invoices, :fee_reimbursements, foreign_key: true
  end
end
