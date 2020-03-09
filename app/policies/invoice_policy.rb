class InvoicePolicy < ApplicationPolicy

  def all_index?
    user.admin?
  end

  def index?
    return true if user.admin?
    return true if record.blank?

    event_ids = record.map(&:sponsor).map(&:event).pluck(:id)
    same_event = event_ids.uniq.size == 1
    return false if same_event && Event.find(event_ids.first).is_spend_only
    return true if same_event && user.events.pluck(:id).include?(event_ids.first)
  end

  def new?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def create?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def show?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def archive?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def unarchive?
    user.admin? || record.sponsor.event.users.include?(user)
  end

  def manual_payment?
    user.admin?
  end

  def manually_mark_as_paid?
    user.admin?
  end
end
