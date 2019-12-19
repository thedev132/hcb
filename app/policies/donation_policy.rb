class DonationPolicy < ApplicationPolicy
  def show?
    user.admin?
  end
end
