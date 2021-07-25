# frozen_string_literal: true

class AddAdminOnlyToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :admin_only, :boolean, null: false, default: false
  end
end
