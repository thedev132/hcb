# frozen_string_literal: true

class AddIsPublicToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_public, :boolean, default: false
  end
end
