# frozen_string_literal: true

class AddArchivedAtToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :archived_at, :datetime
  end
end
