class SponsorPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user_has_position?
  end

  def new?
    user.admin? || user_has_position?
  end

  def create?
    user.admin? || user_has_position?
  end

  def update?
    user.admin? || user_has_position?
  end

  def destroy
    user.admin?
  end

  def permitted_attributes
    attrs = [
      :name,
      :contact_email,
      :address_line1,
      :address_line2,
      :address_city,
      :address_state,
      :address_postal_code
    ]

    attrs << :event_id if user.admin?

    attrs
  end

  private

  def user_has_position?
    record.event&.users&.include?(user)
  end
end
