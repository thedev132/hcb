# frozen_string_literal: true

class AddClosedToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :closed, :boolean
  end
end
