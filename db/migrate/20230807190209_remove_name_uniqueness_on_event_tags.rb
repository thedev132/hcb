# frozen_string_literal: true

class RemoveNameUniquenessOnEventTags < ActiveRecord::Migration[7.0]
  def change
    remove_index :event_tags, :name
  end

end
