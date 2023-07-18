# frozen_string_literal: true

class RemoveOrganizedByFromEvents < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :events, :organized_by_hack_clubbers, :boolean
      remove_column :events, :organized_by_teenagers, :boolean
    end
  end

end
