# frozen_string_literal: true

class AddDeletedAtToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :deleted_at, :datetime
  end

end
