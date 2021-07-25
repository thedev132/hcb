# frozen_string_literal: true

class AddHiddenAtToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :hidden_at, :datetime
  end
end
