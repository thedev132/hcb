# frozen_string_literal: true

class RemoveSeenPlatinumAnnouncementFromUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :users, :seen_platinum_announcement }
  end

end
