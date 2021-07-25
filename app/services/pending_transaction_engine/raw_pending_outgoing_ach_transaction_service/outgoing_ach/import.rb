# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingAchTransactionService
    module OutgoingAch
      class Import
        def initialize
        end

        def run
          pending_outgoing_ach_transactions.each do |poat|
            ::RawPendingOutgoingAchTransaction.find_or_initialize_by(ach_transaction_id: poat.id.to_s).tap do |t|
              t.amount_cents = -poat.amount
              t.date_posted = poat.created_at
            end.save!
          end

          nil
        end

        private

        def pending_outgoing_ach_transactions
          @pending_outgoing_ach_transactions ||= AchTransfer.all
        end
      end
    end
  end
end
