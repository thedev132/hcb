# frozen_string_literal: true

class AddLockedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :locked_at, :datetime
  end

end
