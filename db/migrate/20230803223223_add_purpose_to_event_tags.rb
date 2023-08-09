# frozen_string_literal: true

class AddPurposeToEventTags < ActiveRecord::Migration[7.0]
  def change
    add_column :event_tags, :purpose, :string
  end

end
