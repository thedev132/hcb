# frozen_string_literal: true

class ReceiptPolicy < ApplicationPolicy
  def destroy?
    user&.admin? || record&.receiptable&.event&.users&.include?(user)
  end

end
