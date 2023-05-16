# frozen_string_literal: true

class AddActivatedAtToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :activated_at, :datetime
  end

end
