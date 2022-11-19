# frozen_string_literal: true

class AddNewJsonbColumnsForPapertrail < ActiveRecord::Migration[6.1]
  def change
    # safety_assured is required to appease strong_migrations, but this migration is NOT SAFE
    # unless we run a maintenance window to take down the site until it's completed.
    safety_assured do
      rename_column :versions, :object, :old_object
      add_column :versions, :object, :jsonb

      rename_column :versions, :object_changes, :old_object_changes
      add_column :versions, :object_changes, :jsonb
    end
  end

end
