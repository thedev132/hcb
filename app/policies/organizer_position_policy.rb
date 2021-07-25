# frozen_string_literal: true

class OrganizerPositionPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
