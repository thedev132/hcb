# frozen_string_literal: true

module Column
  class WebhooksController < ActionController::Base
    skip_before_action :verify_authenticity_token

    before_action :verify_signature

    def webhook
      @object = params[:data]
      type = params[:type]
      self.send "handle_#{type.tr(".", "_")}"
    ensure
      head :ok
    end

    private

    def handle_ach_incoming_transfer_scheduled
      return if @object[:type].downcase == "credit" || @object[:amount] <= 100 # Allow incoming ACH credits and small debits

      # If this ACH debit is to an org's account number, reject it
      if AccountNumber.exists?(column_id: @object[:account_number_id])
        ColumnService.post("/transfers/ach/#{@object[:id]}/return", return_code: "R08")
      end
    end

    def verify_signature
      signature_valid = ActiveSupport::SecurityUtils.secure_compare(
        OpenSSL::HMAC.hexdigest(
          "SHA256",
          Rails.application.credentials.column.dig(ColumnService::ENVIRONMENT, :webhook_secret),
          request.body.read
        ),
        request.headers["Column-Signature"]
      )

      unless signature_valid
        head :bad_request
      end
    end

  end
end
