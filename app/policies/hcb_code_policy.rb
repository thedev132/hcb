# frozen_string_literal: true

class HcbCodePolicy < ApplicationPolicy
  def show?
    user&.admin? || present_in_events?
  end

  def memo_frame?
    user&.admin?
  end

  def edit?
    user&.admin? || present_in_events?
  end

  def update?
    user&.admin? || present_in_events?
  end

  def comment?
    user&.admin? || present_in_events?
  end

  def attach_receipt?
    user&.admin? || present_in_events?
  end

  def send_receipt_sms?
    user&.admin?
  end

  def dispute?
    user&.admin? || present_in_events?
  end

  def toggle_tag?
    user&.admin? || present_in_events?
  end

  def link_receipt_modal?
    user&.admin? || present_in_events?
  end

  private

  def present_in_events?
    record.events.select { |e| e.try(:users).try(:include?, user) }.present?
  end

end
