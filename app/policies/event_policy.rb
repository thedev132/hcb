class EventPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    record.users.include?(user) || user.admin?
  end

  def by_airtable_id?
    user.admin?
  end

  def edit?
    record.users.include?(user) || user.admin?
  end

  def update?
    record.users.include?(user) || user.admin?
  end

  def destroy?
    user.admin?
  end

  def team?
    user.admin? || record.users.include?(user)
  end

  def card_overview?
    user.admin? || record.users.include?(user)
  end

  def g_suite_overview?
    user.admin? || record.users.include?(user)
  end

  def transfers?
    user.admin? || record.users.include?(user)
  end

  def promotions?
    user.admin? || record.users.include?(user)
  end

  def reimbursements?
    user.admin? || record.users.include?(user)
  end

  def donation_overview?
    user.admin? || record.users.include?(user)
  end
end
