# frozen_string_literal: true

module BankFeeService
  class Nightly
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsMainToFsOperating

    def run
      if BankFee.pending.present? || FeeRevenue.pending.present?
        login_to_svb!

        BankFee.pending.each do |bank_fee|
          ::BankFeeService::ProcessSingle.new(bank_fee_id: bank_fee.id, driver: driver).run
        end

        FeeRevenue.pending.each do |fee_revenue|
          ::FeeRevenueService::ProcessSingle.new(fee_revenue_id: fee_revenue.id, driver: driver).run
        end

        driver.quit
      end

      BankFee.in_transit.each do |bank_fee|
        cpt = bank_fee.canonical_pending_transaction

        next unless cpt
        next unless cpt.settled?

        raise ArgumentError, "anomaly detected when attempting to mark settled bank fee #{bank_fee.id}" if anomaly_detected?(bank_fee: bank_fee)

        begin
          bank_fee.mark_settled!
        rescue => e
          Airbrake.notify(e)
        end
      end

      FeeRevenue.in_transit.each do |fee_revenue|
        if fee_revenue.canonical_transaction
          fee_revenue.mark_settled!
        end
      end
    end

    private

    def anomaly_detected?(bank_fee:)
      ::PendingEventMappingEngine::AnomalyDetection::BadSettledMapping.new(canonical_pending_transaction: bank_fee.canonical_pending_transaction).run
    end

  end
end
