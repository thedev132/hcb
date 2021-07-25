# frozen_string_literal: true

class AddStatusToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :status, :text
    add_index :invoices, :status
  end
end
