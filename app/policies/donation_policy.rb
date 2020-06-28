class DonationPolicy < ApplicationPolicy
  def show?
    record.event.users.include?(user) || user&.admin?
  end

  def all_index?
    user&.admin?
  end
end
