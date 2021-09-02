# frozen_string_literal: true

module MfaCodeService
  class Create
    def initialize(message:)
      @message = message
    end

    def run
      create_attr = {
        message: @body,
        code: code,
        provider: provider
      }

      mfa_code = MfaCode.create!(create_attr)

      # After creating the code, we need to match it to a MfaRequest
      mfa_request = MfaRequest.pending.svb.order(created_at: :desc).last

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
      @body.to_s.include?("SVB code is")
    end


    def code
      if provider == "SVB"
        return ::MfaCodeService::Parsers::SVB.new(@body).run
      end

      nil
    end

  end
end
