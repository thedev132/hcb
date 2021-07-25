# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :sponsor, foreign_key: true
      t.text :stripe_invoice_id
      t.bigint :amount_due
      t.bigint :amount_paid
      t.bigint :amount_remaining
      t.bigint :attempt_count
      t.boolean :attempted
      t.text :stripe_charge_id
      t.string :closed_boolean
      t.text :memo
      t.datetime :due_date
      t.bigint :ending_balance
      t.boolean :forgiven
      t.boolean :paid
      t.bigint :starting_balance
      t.text :statement_descriptor
      t.bigint :subtotal
      t.bigint :tax
      t.decimal :tax_percent
      t.bigint :total
      t.text :item_description
      t.bigint :item_amount
      t.text :item_stripe_id

      t.timestamps
    end
    add_index :invoices, :stripe_invoice_id, unique: true
    add_index :invoices, :item_stripe_id, unique: true
  end
end
