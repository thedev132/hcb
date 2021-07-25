# frozen_string_literal: true

class AddSlugsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :slug, :text
    add_index :invoices, :slug, unique: true
  end
end
