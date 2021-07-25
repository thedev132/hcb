# frozen_string_literal: true

class AddNumberToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :number, :text
  end
end
