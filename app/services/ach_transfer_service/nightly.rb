# frozen_string_literal: true

module AchTransferService
  class Nightly
    def run
      # in_transit -> processed
      AchTransfer.in_transit.each do |ach_transfer|
        cpt = ach_transfer.canonical_pending_transaction

        next unless cpt
        next unless cpt.settled?

        raise ArgumentError, "anomaly detected when attempting to mark deposited ach_transfer #{ach_transfer.id}" if anomaly_detected?(ach_transfer: ach_transfer)

        ach_transfer.mark_deposited!
      end
    end

    def anomaly_detected?(ach_transfer:)
      ::PendingEventMappingEngine::AnomalyDetection::BadSettledMapping.new(canonical_pending_transaction: ach_transfer.canonical_pending_transaction).run
    end
  end
end
