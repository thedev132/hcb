# frozen_string_literal: true

class CreateFeeRevenues < ActiveRecord::Migration[6.1]
  def change
    create_table :fee_revenues do |t|
      t.integer :amount_cents
      t.date :start
      t.date :end

      t.timestamps
    end
  end

end
