# frozen_string_literal: true

class BankAccountPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def update?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    user.admin?
  end

  def reauthenticate?
    user.admin?
  end
end
