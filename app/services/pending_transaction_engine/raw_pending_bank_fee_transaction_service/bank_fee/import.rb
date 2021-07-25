# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingBankFeeTransactionService
    module BankFee
      class Import
        def initialize
        end

        def run
          pending_bank_fee_transactions.each do |pbft|
            ::RawPendingBankFeeTransaction.find_or_initialize_by(bank_fee_transaction_id: pbft.id.to_s).tap do |t|
              t.amount_cents = pbft.amount_cents
              t.date_posted = pbft.created_at
            end.save!
          end

          nil
        end

        private

        def pending_bank_fee_transactions
          @pending_bank_fee_transactions ||= ::BankFee.since_feature_launch.in_transit_or_pending.where("amount_cents < 0")
        end
      end
    end
  end
end
