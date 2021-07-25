# frozen_string_literal: true

class OpsCheckin < ApplicationRecord
  belongs_to :point_of_contact, class_name: "User"
  validates_presence_of :point_of_contact

  def self.streak
    streak_count = 0
    checkin_dates = all.pluck(:created_at).map(&:to_date).uniq
    cursor = Time.now.to_date
    while checkin_dates.include?(cursor) || checkin_dates.include?(cursor.yesterday)
      streak_count += 1
      cursor = cursor.yesterday
    end

    streak_count
  end

  def self.is_cooldown_active?
    # if there was a checkin in the last hour, we're still in cooldown
    where(created_at: 1.hours.ago..Time.now).any?
  end
end
