module DonationService
  class Refund
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsOperatingToFsMain
    include ::Shared::Selenium::TransferFromFsMainToFsOperating

    def initialize(donation_id:)
      @donation_id = donation_id
    end

    def run
      return nil unless donation.event.id == 183 # temporary - only apply to HQ

      login_to_svb!

      ActiveRecord::Base.transaction do
        raise ArgumentError unless donation.remote_refunded?

        donation.mark_refunded!

        transfer_from_fs_main_to_fs_operating!(amount_cents: amount_cents, memo: memo) # make the transfer on remote bank similar to monthly fee service
      end

      sleep 5

      driver.quit
    end

    private

    def amount_cents
      donation.amount
    end

    def memo
      "#{donation.hcb_code} REFUND"
    end

    def donation
      @donation ||= ::Donation.find(@donation_id)
    end
  end
end
