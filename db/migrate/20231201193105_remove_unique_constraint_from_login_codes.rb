# frozen_string_literal: true

class RemoveUniqueConstraintFromLoginCodes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :login_codes, :code,
                 where: "used_at IS NULL",
                 unique: true,
                 algorithm: :concurrently

    add_index :login_codes, :code, algorithm: :concurrently
  end

end
