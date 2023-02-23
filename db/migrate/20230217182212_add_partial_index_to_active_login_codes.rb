# frozen_string_literal: true

class AddPartialIndexToActiveLoginCodes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :login_codes, :code,
              where: "used_at IS NULL",
              unique: true,
              algorithm: :concurrently
  end

end
