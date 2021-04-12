class DonationPolicy < ApplicationPolicy
  def show?
    record.event.users.include?(user) || user&.admin?
  end

  def index?
    user&.admin?
  end

  def refund?
    user&.admin?
  end
end
