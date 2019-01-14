class InvoicePolicy < ApplicationPolicy
  def index?
    user.admin? || record.event.users.include?(user)
  end

  def new?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def create?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def show?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def manual_payment?
    user.admin?
  end

  def manually_mark_as_paid?
    user.admin?
  end
end
