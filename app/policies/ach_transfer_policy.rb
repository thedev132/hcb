class AchTransferPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    record.event.users.include?(user) || user.admin?
  end

  def create?
    record.event.users.include?(user) || user.admin?
  end

  def show?
    record.event.users.include?(user) || user.admin?
  end

  def start_approval?
    user.admin?
  end

  def approve?
    user.admin?
  end

  def reject?
    user.admin?
  end

end
