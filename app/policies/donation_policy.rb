class DonationPolicy < ApplicationPolicy
  def show?
    admin_or_teammember
  end

  def all_index?
    user&.admin?
  end
end
