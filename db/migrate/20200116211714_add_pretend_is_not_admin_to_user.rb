# frozen_string_literal: true

class AddPretendIsNotAdminToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pretend_is_not_admin, :boolean, null: false, default: false
  end
end
