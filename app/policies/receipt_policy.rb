# frozen_string_literal: true

class ReceiptPolicy < ApplicationPolicy
  def destroy?
    user&.admin? || (user && record.user == user)
  end
end
