# frozen_string_literal: true

class EventTagPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def toggle_event_tag?
    user.admin?
  end

end
