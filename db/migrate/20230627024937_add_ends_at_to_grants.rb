# frozen_string_literal: true

class AddEndsAtToGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :grants, :ends_at, :datetime
  end

end
