# frozen_string_literal: true

class AddReimburseableAndFeeReimbursementReferencesToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :reimbursable, :boolean, default: true
    add_reference :invoices, :fee_reimbursement, foreign_key: true
  end
end
