class InvoicePolicy < ApplicationPolicy
  def create?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def show?
    user.admin? || record.sponsor.event.users.include?(user)
  end
end
