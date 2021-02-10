class CheckPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def new?
    is_public || admin_or_user
  end

  def create?
    user&.admin? || record.users.include?(user) # dirty implementation here. record is event (temporary)
  end

  def show?
    is_public || admin_or_user
  end

  def view_scan?
    admin_or_user
  end

  def start_void?
    admin_or_user
  end

  def void?
    admin_or_user
  end

  def edit?
    admin_or_user
  end

  def update?
    admin_or_user
  end

  def refund_get?
    user&.admin?
  end

  def refund?
    user&.admin?
  end

  def start_approval?
    user&.admin?
  end

  def approve?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def export?
    user&.admin?
  end

  private

  def admin_or_user
    user&.admin? || record.lob_address.event.users.include?(user)
  end

  def is_public
    record.lob_address.event.is_public?
  end
end
