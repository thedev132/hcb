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

          return likely_invoice_or_donation_for_fee_refund if fee_refund?

          return likely_donation if donation?

          return likely_disbursement if disbursement?

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

      def likely_invoice_or_donation_for_fee_refund
        fee_reimbursement = FeeReimbursement.where("transaction_memo ilike '%#{likely_donation_for_fee_refund_hex_random_id}%'").first

        return nil unless fee_reimbursement

        fee_reimbursement.try(:invoice) || fee_reimbursement.try(:donation)
      end

      def likely_donation
        potential_donation_payouts = event.donation_payouts.where("donation_payouts.statement_descriptor ilike 'DONATE #{likely_donation_short_name}%' and donation_payouts.amount = #{amount_cents}")

        return nil unless potential_donation_payouts.present?

        potential_donation_payouts.first.donation
      end

      def likely_disbursement
        Disbursement.where(id: likely_disbursement_id).first
      end

      def event
        @event ||= @canonical_transaction.event
      end
    end
  end
end
