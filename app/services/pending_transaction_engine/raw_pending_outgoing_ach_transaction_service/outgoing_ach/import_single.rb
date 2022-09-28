# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingAchTransactionService
    module OutgoingAch
      class ImportSingle
        def initialize(ach_transfer:)
          @ach_transfer = ach_transfer
        end

        def run
          rpoat = ::RawPendingOutgoingAchTransaction.find_or_initialize_by(ach_transaction_id: @ach_transfer.id.to_s).tap do |t|
            t.amount_cents = -@ach_transfer.amount
            t.date_posted = @ach_transfer.created_at
          end

          rpoat.save!

          rpoat
        end

      end
    end
  end
end
