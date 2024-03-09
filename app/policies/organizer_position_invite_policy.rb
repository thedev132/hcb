# frozen_string_literal: true

class OrganizerPositionInvitePolicy < ApplicationPolicy
  def index?
    user&.admin? || record.event&.users&.include?(user)
  end

  def new?
    user&.admin? || record.event&.users&.include?(user)
  end

  def create?
    user&.admin? || (record.event.users.include?(user) && OrganizerPosition.find_by(user, event: record.event)&.manager?)
  end

  def show?
    user&.admin? || record.user == user
  end

  def accept?
    record.user == user
  end

  def reject?
    record.user == user
  end

  def cancel?
    user&.admin? || (record.event.users.include?(user) && (current_user_is_manager? || record.sender == user))
  end

  def toggle_signee_status?
    user&.admin?
  end

  def change_position_role?
    user&.admin? || organizer_signed_in?(as: :manager)
  end

  private

  def current_user_is_manager?
    OrganizerPosition.find_by(user:, event: record.event)&.manager?
  end

end
