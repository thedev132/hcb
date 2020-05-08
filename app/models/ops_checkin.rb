class OpsCheckin < ApplicationRecord
  belongs_to :point_of_contact, class_name: 'User'
  validates_presence_of :point_of_contact

  def self.streak
    # returns a count of days with a checkin
    streak_count = 0
    today = Time.now.to_date
    checkin_dates = all.map{ |oc| oc.created_at.to_date }.uniq
    checkin_dates.reduce(today) do |memo, date|
      yesterday = memo.yesterday.to_date
      if date == yesterday || date == today
        streak_count += 1
        memo = date
      end
    end

    streak_count
  end

  def self.is_cooldown_active?
    # if there was a checkin in the last hour, we're still in cooldown
    where(created_at: 1.hours.ago..Time.now).any?
  end
end
