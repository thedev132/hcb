class HcbCodePolicy < ApplicationPolicy
  def show?
    user&.admin? || present_in_events?
  end

  def comment?
    user&.admin? || present_in_events?
  end

  def receipt?
    record.date > 10.days.ago || user&.admin? || present_in_events?
  end

  def attach_receipt?
    record.date > 10.days.ago || user&.admin? || present_in_events?
  end

  private

  def present_in_events?
    record.events.select { |e| e.try(:users).try(:include?, user) }.present?
  end
end
