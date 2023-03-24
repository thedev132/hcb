# frozen_string_literal: true

class DropExports < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :exports, :users
    drop_table :exports
  end

end
