# frozen_string_literal: true

class AddManualPaymentFieldsToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :manually_marked_as_paid_at, :datetime
    add_reference :invoices, :manually_marked_as_paid_user, foreign_key: { to_table: :users }
    add_column :invoices, :manually_marked_as_paid_reason, :text
  end
end
