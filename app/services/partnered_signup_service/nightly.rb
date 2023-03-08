# frozen_string_literal: true

module PartneredSignupService
  class Nightly
    def run
      api = Partners::Docusign::Api.instance
      PartneredSignup.applicant_signed.with_envelope.each do |partnered_signup|
        begin
          res = api.get_envelope partnered_signup.docusign_envelope_id
          Rails.logger.info "put state transition here" if res.status == "completed"
        rescue DocuSign_eSign::ApiError
          # TODO: signal error
          nil
        end
      end
    end

  end
end
