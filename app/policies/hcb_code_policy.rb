class HcbCodePolicy < ApplicationPolicy
  def show?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end

  def comment?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end

  def receipt?
    record.date > 10.days.ago || user&.admin? || record.event.try(:users).try(:include?, user)
  end

  def attach_receipt?
    record.date > 10.days.ago || user&.admin? || record.event.try(:users).try(:include?, user)
  end
end
