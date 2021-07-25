# frozen_string_literal: true

class OrganizerPositionDeletionRequestPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    event = record.organizer_position.event
    user.admin? ||
      (event.users.include?(user) && event.organizer_positions.include?(record.organizer_position))
  end

  def create?
    event = record.organizer_position.event
    user.admin? ||
      (event.users.include?(user) && event.organizer_positions.include?(record.organizer_position))
  end

  def show?
    user.admin?
  end

  def close?
    user.admin?
  end

  def open?
    user.admin?
  end
end
