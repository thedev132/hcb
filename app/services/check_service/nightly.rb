module CheckService
  class Nightly
    def run
      # process checks ready to be sent (check created on lob)
      scheduled_checks.where("send_date <= ?", Time.now.utc).each do |check|
        ::CheckService::Send.new(check_id: check.id).run
      end

      # in_transit_and_processed -> deposited
      in_transit_and_processed_checks.each do |check|
        # 1. check if it has cleared the pending transaction
        id = check.id

        rpocts = RawPendingOutgoingCheckTransaction.where(check_transaction_id: id)

        if rpocts.blank?
          Airbrake.notify("check: #{id} missing a raw_pending_outgoing_check_transaction")
          next
        end

        if rpocts.count > 1
          Airbrake.notify("check: #{id} had more than 1 match") 
          next
        end

        rpoct = rpocts.first

        cpts = CanonicalPendingTransaction.where(raw_pending_outgoing_check_transaction_id: rpoct.id)

        if cpts.blank?
          Airbrake.notify("check: #{id} missing a linked canonical pending transaction") 
          next
        end

        if cpts.count > 1
          Airbrake.notify("check: #{id} had more than 1 match of canonical pending transactions") 
          next
        end

        cpt = cpts.first

        cts = cpt.canonical_transactions

        next unless cts.present?

        if cts.count > 1
          Airbrake.notify("check: #{id} had more than 1 match of canonical transactions") 
          next
        end

        ct = cts.first

        # 2. if it is has, then mark deposited
        if ct.present?
          check.mark_deposited! 
        end
      end
    end

    private

    def scheduled_checks
      Check.scheduled
    end

    def in_transit_and_processed_checks
      Check.in_transit_and_processed
    end
  end
end
