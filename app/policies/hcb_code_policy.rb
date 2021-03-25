class HcbCodePolicy < ApplicationPolicy
  def comment?
    user&.admin? || record.event.try(:users).try(:include?, user)
  end
end
