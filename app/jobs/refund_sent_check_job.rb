class RefundSentCheckJob < ApplicationJob
  queue_as :default

  def perform(check)
    return if check.deposited? || check.pending_void? || check.voided?

    CheckMailer.undeposited(check: check)
    CheckMailer.undeposited_organizers(check: check)
    check.void!
  end
end
