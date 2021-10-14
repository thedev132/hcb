# frozen_string_literal: true

class HcbCodePolicy < ApplicationPolicy
  def show?
    user&.admin? || present_in_events?
  end

  def comment?
    user&.admin? || present_in_events?
  end

  def receipt?
    user&.admin? || present_in_events? || record.date > 10.days.ago
  end

  def attach_receipt?
    user&.admin? || present_in_events? || record.date > 10.days.ago
  end

  def dispute?
    user&.admin? || present_in_events?
  end

  private

  def present_in_events?
    record.events.select { |e| e.try(:users).try(:include?, user) }.present?
  end
end
