# frozen_string_literal: true

class OrganizerPositionPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end

  def set_index?
    record.user == user
  end

end
