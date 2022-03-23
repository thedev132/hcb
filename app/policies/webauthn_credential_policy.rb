# frozen_string_literal: true

class WebauthnCredentialPolicy < ApplicationPolicy
  def destroy?
    user.admin? || record.user == user
  end

end
