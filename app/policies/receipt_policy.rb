# frozen_string_literal: true

class ReceiptPolicy < ApplicationPolicy
  def destroy?
    user&.admin? || record&.receiptable&.event&.users&.include?(user) ||
      (record&.receiptable.nil? && record&.user == user) # Checking if receiptable is nil prevents unauthorized deletion when user no longer has access to an org
  end

  def link?
    record.receiptable.nil? && record.user == user
  end

end
