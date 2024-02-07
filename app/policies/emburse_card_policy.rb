# frozen_string_literal: true

class EmburseCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    record.event.users.include?(user) || user&.admin?
  end

end
