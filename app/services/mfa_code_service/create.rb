# frozen_string_literal: true

module MfaCodeService
  class Create
    def initialize(message:)
      @message = message
    end

    def run
      create_attr = {
        message: @message,
        code: code,
        provider: provider
      }

      mfa_code = MfaCode.create!(create_attr)

      return if provider == "unknown"

      # After creating the code, we attempt to match it to a MfaRequest
      mfa_request = MfaRequest.pending.where(provider: provider).order(created_at: :asc).last

      return if mfa_request.nil?

      ActiveRecord::Base.transaction do
        mfa_request.update_column(:mfa_code_id, mfa_code.id)
        mfa_request.mark_received!

        mfa_request
      end
    end

    private

    def provider
      return "SVB" if likely_svb?

      "unknown"
    end

    def likely_svb?
      @message.to_s.include?("SVB login code is")
    end

    def code
      if provider == "SVB"
        return ::MfaCodeService::Parsers::Svb.new(message: @message).run
      end

      nil
    end
  end
end
