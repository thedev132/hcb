# frozen_string_literal: true

class AddIsIndexableToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :is_indexable, :boolean, default: false # set to false for existing orgs
    change_column_default :events, :is_indexable, true # default to true for new orgs
  end

end
