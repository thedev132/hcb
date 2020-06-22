class DonationPolicy < ApplicationPolicy
  def show?
    user&.admin?
  end

  def index?
    user&.admin?
  end
end
