# frozen_string_literal: true

class CreateJoinTableHcbCodesInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :hcb_code_personal_transactions do |t|
      t.references :hcb_code, foreign_key: true
      t.references :invoice, foreign_key: true
      t.references :reporter, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
