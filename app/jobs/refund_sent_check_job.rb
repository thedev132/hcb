# frozen_string_literal: true

class RefundSentCheckJob < ApplicationJob
  queue_as :default

  def perform(check)
    return if check.deposited? || check.pending_void? || check.voided?

    CheckMailer.with(check: check).undeposited.deliver_later
    #CheckMailer.with(check: check).undeposited_organizers.deliver_later
    check.void!
  end
end
