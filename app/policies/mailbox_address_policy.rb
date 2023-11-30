# frozen_string_literal: true

class MailboxAddressPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def show?
    record.user == user
  end

  def activate?
    record.user == user
  end

end
