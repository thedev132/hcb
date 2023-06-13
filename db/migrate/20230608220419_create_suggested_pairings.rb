# frozen_string_literal: true

class CreateSuggestedPairings < ActiveRecord::Migration[7.0]
  def change
    create_table :suggested_pairings do |t|
      t.belongs_to :receipt, null: false
      t.belongs_to :hcb_code, null: false

      t.float :distance

      t.datetime :ignored_at
      t.datetime :accepted_at
      t.string :aasm_state

      t.index [:receipt_id, :hcb_code_id], unique: true

      t.timestamps
    end
  end

end
