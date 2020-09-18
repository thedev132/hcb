class EventPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def new?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def show?
    is_public || user_or_admin
  end

  def dashboard_stats?
    is_public || user_or_admin
  end

  def by_airtable_id?
    user&.admin?
  end

  def edit?
    user_or_admin
  end

  def update?
    user_or_admin
  end

  def destroy?
    user&.admin?
  end

  def team?
    is_public || user_or_admin
  end

  def emburse_card_overview?
    is_public || user_or_admin
  end

  def card_overview?
    is_public || user_or_admin
  end

  def g_suite_overview?
    is_public || user_or_admin
  end

  def g_suite_create?
    user_or_admin
  end

  def g_suite_verify?
    user_or_admin
  end

  def transfers?
    is_public || user_or_admin
  end

  def promotions?
    is_public || user_or_admin
  end

  def reimbursements?
    is_public || user_or_admin
  end

  def donation_overview?
    is_public || user_or_admin
  end

  def user_or_admin
    user&.admin? || record.users.include?(user)
  end

  def is_public
    record.is_public?
  end
end
