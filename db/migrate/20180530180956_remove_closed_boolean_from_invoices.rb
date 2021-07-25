# frozen_string_literal: true

class RemoveClosedBooleanFromInvoices < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :closed_boolean, :string
  end
end
