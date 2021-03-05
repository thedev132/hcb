# frozen_string_literal: true

module AchTransferService
  class Nightly
    def run
      # in_transit -> processed
      AchTransfer.in_transit.each do |ach_transfer|
        # 1. check if it has cleared the pending transaction
        id = ach_transfer.id

        rpoats = RawPendingOutgoingAchTransaction.where(ach_transaction_id: id)

        if rpoats.blank?
          Airbrake.notify("ach_transfer: #{id} missing a raw_pending_outgoing_ach_transaction")
          next
        end

        if rpoats.count > 1
          Airbrake.notify("ach_transfer: #{id} had more than 1 match") 
          next
        end

        rpoat = rpoats.first

        cpts = CanonicalPendingTransaction.where(raw_pending_outgoing_ach_transaction_id: rpoat.id)

        if cpts.blank?
          Airbrake.notify("ach_transfer: #{id} missing a linked canonical pending transaction") 
          next
        end

        if cpts.count > 1
          Airbrake.notify("ach_transfer: #{id} had more than 1 match of canonical pending transactions") 
          next
        end

        cpt = cpts.first

        cts = cpt.canonical_transactions

        next unless cts.present?

        if cts.count > 1
          Airbrake.notify("ach_transfer: #{id} had more than 1 match of canonical transactions") 
          next
        end

        ct = cts.first

        # 2. if it is has, then mark deposited
        if ct.present?
          ach_transfer.mark_deposited! 
        end
      end
    end
  end
end
