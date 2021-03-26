class HcbCodePolicy < ApplicationPolicy
  def show?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end

  def comment?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end

  def receipt?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end
end
