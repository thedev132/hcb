# frozen_string_literal: true

module Column
  class AccountNumberPolicy < ApplicationPolicy
    def create?
      user&.admin? || record.event.users.include?(user)
    end

  end
end
