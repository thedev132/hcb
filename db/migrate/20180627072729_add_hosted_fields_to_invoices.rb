# frozen_string_literal: true

class AddHostedFieldsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :hosted_invoice_url, :text
    add_column :invoices, :invoice_pdf, :text
  end
end
