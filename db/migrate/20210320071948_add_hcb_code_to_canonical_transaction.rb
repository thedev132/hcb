# frozen_string_literal: true

class AddHcbCodeToCanonicalTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :canonical_transactions, :hcb_code, :text
  end
end
