# frozen_string_literal: true

class ReceiptPolicy < ApplicationPolicy
  def destroy?
    user&.admin? || record&.event&.users&.include?(user)
  end

end
