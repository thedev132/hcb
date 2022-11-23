# frozen_string_literal: true

class DropYamlColumnsFromPaperTrailVersions < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :versions, :old_object
      remove_column :versions, :old_object_changes
    end
  end

end
