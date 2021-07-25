# frozen_string_literal: true

class AddClubAirtableUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :club_airtable_id, :text
    add_index :events, :club_airtable_id, unique: true
  end
end
