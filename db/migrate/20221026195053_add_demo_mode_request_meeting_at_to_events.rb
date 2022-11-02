# frozen_string_literal: true

class AddDemoModeRequestMeetingAtToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :demo_mode_request_meeting_at, :datetime, null: true
  end

end
