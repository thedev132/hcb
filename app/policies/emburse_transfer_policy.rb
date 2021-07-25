# frozen_string_literal: true

class EmburseTransferPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def edit?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def cancel?
    record.creator == user
  end

  def accept?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def export?
    user&.admin?
  end

  private

  def is_public
    record.event.is_public?
  end
end
