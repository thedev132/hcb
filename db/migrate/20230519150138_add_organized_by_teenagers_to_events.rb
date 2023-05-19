# frozen_string_literal: true

class AddOrganizedByTeenagersToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :organized_by_teenagers, :boolean, null: false, default: false
  end

end
