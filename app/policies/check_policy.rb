class CheckPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def create?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def show?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def start_void?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def void?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def edit?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def update?
    record.lob_address.event.users.include?(user) || user.admin?
  end

  def refund_get?
    user.admin?
  end

  def refund?
    user.admin?
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

  def export?
    user.admin?
  end
end
