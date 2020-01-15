class DocumentPolicy < ApplicationPolicy
  def common_index?
    user.admin?
  end

  def index?
    return true if user.admin?
    return true if record.blank?

    event_ids = record.map(&:event).pluck(:id)
    same_event = event_ids.uniq.size == 1
    return true if same_event && user.events.pluck(:id).include?(event_ids.first)
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def download?
    user.admin? || record.event.nil? || record.event.users.include?(user)
  end

  def fiscal_sponsorship_letter?
    return true if user.admin?
    # if there are no documents then user can't access fiscal sponsorship doc
    return false if record.blank?

    # get all event ids in document collection
    event_ids = record.map(&:event).pluck(:id)
    # boolean for if all of them are the same
    same_event = event_ids.uniq.size == 1
    # if all the event ids are the same and the user accessing owns that event, give access.
    return true if same_event && user.events.pluck(:id).include?(event_ids.first) && Event.find(event_ids[0]).has_fiscal_sponsorship_document
  end
end
