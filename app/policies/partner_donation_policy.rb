# frozen_string_literal: true

class PartnerDonationPolicy < ApplicationPolicy
  def show?
    record.event.users.include?(user) || user&.admin?
  end

  def export?
    record.event.users.include?(user) || user&.admin?
  end
end
