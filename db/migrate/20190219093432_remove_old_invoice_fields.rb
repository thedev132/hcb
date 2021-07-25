# frozen_string_literal: true

class RemoveOldInvoiceFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :paid
    remove_column :invoices, :forgiven
  end
end
