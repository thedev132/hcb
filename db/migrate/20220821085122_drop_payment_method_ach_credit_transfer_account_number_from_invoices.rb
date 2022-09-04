# frozen_string_literal: true

class DropPaymentMethodAchCreditTransferAccountNumberFromInvoices < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :invoices, :payment_method_ach_credit_transfer_account_number
    end
  end

end
