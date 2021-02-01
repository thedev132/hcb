module TransactionEngine
  module SyntaxSugarService
    class LinkedObject
      include ::TransactionEngine::SyntaxSugarService::Shared

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        if memo.present?

          return likely_check if outgoing_check?

          return likely_ach if outgoing_ach?

          return likely_invoice if incoming_invoice?

          nil
        end
      end

      private

      def likely_check
        event.checks.where(check_number: likely_outgoing_check_number).first
      end

      def likely_ach
        event.ach_transfers.where("recipient_name ilike '%#{likely_outgoing_ach_name}%' and amount = #{-amount_cents}").first # TODO: add smarts where multiple ach transfers to same person with same value
      end

      def likely_invoice
        potential_payouts = event.payouts.where("invoice_payouts.statement_descriptor ilike 'PAYOUT #{likely_incoming_invoice_short_name}%' and invoice_payouts.amount = #{amount_cents}")

        return nil unless potential_payouts.present?

        potential_payouts.first.invoice # TODO: add smarts where multiple potential payouts to same person with same value
      end

      def event
        @event ||= @canonical_transaction.event
      end
    end
  end
end
