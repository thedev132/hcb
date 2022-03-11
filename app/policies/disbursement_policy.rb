# frozen_string_literal: true

class DisbursementPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def new?
    user.admin? || user_associated_with_events?
  end

  def create?
    user.admin? || user_associated_with_events?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def mark_fulfilled?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def pending_disbursements?
    user.admin?
  end

  private

  def user_associated_with_events?
    record.nil? or record.users.includes(user)
  end

end
