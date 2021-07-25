# frozen_string_literal: true

class RemoveArchivedAtFromSponsors < ActiveRecord::Migration[5.2]
  def change
    remove_column :sponsors, :archived_at, :datetime
  end
end
