# frozen_string_literal: true

class CreateEmburseTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :emburse_transactions do |t|
      t.string :emburse_id
      t.integer :amount
      t.integer :state
      t.string :emburse_department_id
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
