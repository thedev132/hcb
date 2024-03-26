# frozen_string_literal: true

module Reimbursement
  module PayoutHoldingService
    class Nightly
      def run
        clearinghouse = Event.find_by(id: EventMappingEngine::EventIds::REIMBURSEMENT_CLEARING)
        Reimbursement::PayoutHolding.settled.find_each(batch_size: 100) do |payout_holding|
          if payout_holding.report.user.payout_method.is_a?(User::PayoutMethod::Check)
            begin
              check = clearinghouse.increase_checks.build(
                memo: "Reimbursement for #{payout_holding.report.name}."[0...40],
                amount: payout_holding.amount_cents,
                payment_for: "Reimbursement for #{payout_holding.report.name}.",
                recipient_name: payout_holding.report.user.name,
                address_line1: payout_holding.report.user.payout_method.address_line1,
                address_line2: payout_holding.report.user.payout_method.address_line2,
                address_city: payout_holding.report.user.payout_method.address_city,
                address_state: payout_holding.report.user.payout_method.address_state,
                recipient_email: payout_holding.report.user.email,
                send_email_notification: false,
                address_zip: payout_holding.report.user.payout_method.address_postal_code,
                user: User.find_by(email: "hcb@hackclub.com")
              )
              check.save!
              check.send_check!
              payout_holding.mark_sent!
            rescue => e
              Airbrake.notify(e)
            end
          elsif payout_holding.report.user.payout_method.is_a?(User::PayoutMethod::AchTransfer)
            begin
              ach_transfer = clearinghouse.ach_transfers.build(
                amount: payout_holding.amount_cents,
                payment_for: "Reimbursement for #{payout_holding.report.name}.",
                recipient_name: payout_holding.report.user.name,
                recipient_email: payout_holding.report.user.email,
                send_email_notification: false,
                routing_number: payout_holding.report.user.payout_method.routing_number,
                account_number: payout_holding.report.user.payout_method.account_number,
                creator: User.find_by(email: "hcb@hackclub.com")
              )
              ach_transfer.save!
              ach_transfer.approve!(User.find_by(email: "hcb@hackclub.com"))
              payout_holding.mark_sent!
            rescue => e
              Airbrake.notify(e)
            end
          else
            raise ArgumentError, "🚨⚠️ unsupported payout method!"
          end

        end
      end

    end
  end
end
