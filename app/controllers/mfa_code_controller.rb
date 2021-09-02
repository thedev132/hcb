# frozen_string_literal: true

class MfaCodeController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user
  
  # Twilio Messaging webhook
  # They give us 15 seconds to respond
  # https://www.twilio.com/docs/messaging/guides/webhook-request
  def messaging
    ::MfaCodeService::Create.new(message: params[:Body]).run

    # Don't reply to incoming sms message
    # https://support.twilio.com/hc/en-us/articles/223134127-Receive-SMS-and-MMS-Messages-without-Responding
    respond_to do |format|
      format.xml { render xml: "<Response></Response>" }
    end
  end
end
