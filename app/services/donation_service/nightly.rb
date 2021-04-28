module DonationService
  class Nightly
    def run
      Donation.succeeded.each do |donation|
        cpt = donation.canonical_pending_transaction

        next unless cpt
        next unless cpt.settled?

        raise ArgumentError, "anomaly detected when attempting to mark deposited donation #{donation.id}" if anomaly_detected?(donation: donation)

        begin
          donation.mark_deposited! unless donation.deposited?
        rescue => e
          Airbrake.notify(e)
        end
      end
    end

    def anomaly_detected?(donation:)
      ::PendingEventMappingEngine::AnomalyDetection::BadSettledMapping.new(canonical_pending_transaction: donation.canonical_pending_transaction).run
    end
  end
end
