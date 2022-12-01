# frozen_string_literal: true

module CanonicalPendingTransactionJob
  class SendTwilioMessage < ApplicationJob
    include Rails.application.routes.url_helpers
    def perform(cpt_id:, user_id:)
      @cpt = CanonicalPendingTransaction.find(cpt_id)
      @user = User.find(user_id)

      # rubocop:disable Naming/VariableNumber
      return unless Flipper.enabled?(:sms_receipt_notifications_2022_11_23, @user)
      # rubocop:enable Naming/VariableNumber

      message = "Your card was charged $#{@cpt.amount.abs} for '#{@cpt.memo}'. Plz upload it here: #{attach_receipt_hcb_code_url @cpt.hcb_code}"
      hcb_code = @cpt.local_hcb_code

      TwilioMessageService::Send.new(@user, message, hcb_code: hcb_code).run!
    end

  end
end
