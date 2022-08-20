# frozen_string_literal: true

class AddTagToHcbCode < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :hcb_codes, :tag, null: true, index: { algorithm: :concurrently }
  end

end
