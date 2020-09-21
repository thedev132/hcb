class DonationPolicy < ApplicationPolicy
  def show?
    record.event.users.include?(user) || user&.admin?
  end

  def index?
    user&.admin?
  end
end
