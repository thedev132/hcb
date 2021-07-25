# frozen_string_literal: true

class AddMissingFieldsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :livemode, :boolean

    add_column :invoices, :payment_method_type, :text
    add_column :invoices, :payment_method_card_brand, :text
    add_column :invoices, :payment_method_card_checks_address_line1_check, :text
    add_column :invoices, :payment_method_card_checks_address_postal_code_check, :text
    add_column :invoices, :payment_method_card_checks_cvc_check, :text
    add_column :invoices, :payment_method_card_country, :text
    add_column :invoices, :payment_method_card_exp_month, :text
    add_column :invoices, :payment_method_card_exp_year, :text
    add_column :invoices, :payment_method_card_funding, :text
    add_column :invoices, :payment_method_card_last4, :text

    add_column :invoices, :payment_method_ach_credit_transfer_bank_name, :text
    add_column :invoices, :payment_method_ach_credit_transfer_routing_number, :text
    add_column :invoices, :payment_method_ach_credit_transfer_account_number, :text
    add_column :invoices, :payment_method_ach_credit_transfer_swift_code, :text
  end
end
