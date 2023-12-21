# frozen_string_literal: true

module Column
  class AccountNumberPolicy < ApplicationPolicy
    def create?
      user&.admin?
    end

  end
end
