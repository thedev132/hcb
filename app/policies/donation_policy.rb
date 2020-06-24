class DonationPolicy < ApplicationPolicy
  def show?
    user&.admin?
  end

  def all_index?
    user&.admin?
  end
end
