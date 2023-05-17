# frozen_string_literal: true

class ReceiptablePolicy < ApplicationPolicy
  def link?
    user&.admin? || present_in_events?
  end

  def link_modal?
    user&.admin? || present_in_events?
  end

  def upload?
    user&.admin? || present_in_events?
  end

  private

  def present_in_events?
    # Assumption: Receiptable has an association to Event
    events = record.try(:events) || [record.event]
    events.select { |e| e.try(:users).try(:include?, user) }.present?
  end

end
