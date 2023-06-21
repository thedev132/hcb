# frozen_string_literal: true

module ReceiptReportJob
  class Send < ApplicationJob
    def perform(user_id, force_send: false)
      @user = User.includes(:stripe_cards).find user_id

      return unless force_send ||
                    @user.receipt_report_weekly? ||
                    @user.receipt_report_monthly?
      return unless hcb_ids.any?

      mailer = ReceiptableMailer.with(user_id:,
                                      hcb_ids:)

      mailer.receipt_report.deliver_later
    end

    def hcb_ids
      # This code is grabbed from static_pages#my_missing_receipts_list
      @hcb_ids ||= begin
        ids = []
        @user.stripe_cards.each do |card|
          card.hcb_codes.missing_receipt.each do |hcb_code|
            next unless hcb_code.receipt_required?

            ids << hcb_code.id
          end
        end
        ids
      end
    end

  end
end
