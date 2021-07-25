# frozen_string_literal: true

class FeeReimbursementPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def mark_as_unprocessed?
    user.admin?
  end

  def mark_as_processed?
    user.admin?
  end

  def export?
    user.admin?
  end
end
