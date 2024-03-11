# frozen_string_literal: true

class DisbursementPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def new?
    return true if user.admin?

    return false if !record.destination_event.nil? && !record.destination_event.users.include?(user)
    return false if !record.source_event.nil? && !record.source_event.users.include?(user)
    return false unless OrganizerPosition.find_by(user_id: user.id, event_id: record.source_event.id).manager?
    return true


      # FAIL if the destinaition is not null and the user is not in dest
      # FAIL if the soruce  is not null AND the user is not in src
      # FAIL if user is not manager

    # user.admin? || (user_associated_with_events? && user_who_can_transfer?)
  end

  def create?
    user.admin? || (!record.outernet_guild? && user_associated_with_events?) && user_who_can_transfer?
  end

  def transfer_confirmation_letter?
    admin_or_user?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def mark_fulfilled?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def pending_disbursements?
    user.admin?
  end

  private

  def admin_or_user?
    user&.admin? || record.event.users.include?(user)
  end

  def user_who_can_transfer?
    user&.admin? || EventPolicy.new(user, record.event).new_transfer?
  end

  def user_associated_with_events?
    (record.nil? or record.users.include?(user)) and
      Flipper.enabled?(:transfers_2022_04_21, user)
  end

end
