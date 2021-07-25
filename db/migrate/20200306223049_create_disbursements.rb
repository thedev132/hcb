# frozen_string_literal: true

class CreateDisbursements < ActiveRecord::Migration[5.2]
  def change
    create_table :disbursements do |t|
      t.references :event, foreign_key: true
      t.integer :amount
      t.string :name
      t.datetime :fulfilled_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
