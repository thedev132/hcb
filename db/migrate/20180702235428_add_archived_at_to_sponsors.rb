# frozen_string_literal: true

class AddArchivedAtToSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :sponsors, :archived_at, :timestamp
  end
end
