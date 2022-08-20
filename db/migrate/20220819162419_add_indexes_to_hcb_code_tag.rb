# frozen_string_literal: true

class AddIndexesToHcbCodeTag < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :hcb_codes_tags, [:hcb_code_id, :tag_id], unique: true, algorithm: :concurrently
  end

end
