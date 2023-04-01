# frozen_string_literal: true

module CanonicalPendingTransactionJob
  class SendTwilioMessage < ApplicationJob
    include HcbCodeHelper # for attach_receipt_url

    # This is a heuristic to avoid sending SMS for online charges. This isn't
    # always correct.
    IN_PERSON_AUTH_METHODS = %w[keyed_in swipe chip contactless].freeze

    def perform(cpt_id:, user_id:)
      @cpt = CanonicalPendingTransaction.find(cpt_id)
      @user = User.find(user_id)

      return unless Flipper.enabled?(:sms_receipt_notifications_2022_11_23, @user)

      return unless IN_PERSON_AUTH_METHODS.include? auth_method

      hcb_code = @cpt.local_hcb_code
      message = "Your card was charged $#{@cpt.amount.abs} at '#{@cpt.memo}'. Upload your receipt: #{attach_receipt_url hcb_code}"

      TwilioMessageService::Send.new(@user, message, hcb_code: hcb_code).run!
    end

    private

    def auth_method
      @cpt&.raw_pending_stripe_transaction&.authorization_method
    end

  end
end
