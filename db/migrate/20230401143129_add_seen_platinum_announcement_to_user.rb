# frozen_string_literal: true

class AddSeenPlatinumAnnouncementToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :seen_platinum_announcement, :boolean, default: false
  end

end
