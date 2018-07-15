class SponsorPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user_has_position?
  end

  def new?
    user.admin? || user_has_position?
  end

  def create?
    user.admin? || user_has_position?
  end

  def update?
    user.admin? || user_has_position?
  end

  def destroy
    user.admin?
  end

  private

  def user_has_position?
    record.event&.users&.include?(user)
  end
end
