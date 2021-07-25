# frozen_string_literal: true

class AddUniqueIndexToHcbCodesHcbCode < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :hcb_codes, :hcb_code, unique: true, algorithm: :concurrently
  end
end
