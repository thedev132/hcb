# frozen_string_literal: true

class AddPaymentMethodAchCreditTransferAccountNumberKeyCiphertextToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :payment_method_ach_credit_transfer_account_number_ciphertext, :text
  end

end
