# frozen_string_literal: true

module Partners
  module Docusign
    class ArchiveContract
      def initialize(partnered_signup)
        @partnered_signup = partnered_signup
      end

      def run
        # Hardcode ID to 1 since we only have 1 document for now
        file = api.get_document(@partnered_signup.docusign_envelope_id, '1').open
        blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: 'contract.pdf')
        doc = Document.new(name: 'signup_contract', user_id: @partnered_signup.user_id)
        doc.file = blob
        doc.save!
      end

    end

  end
end
