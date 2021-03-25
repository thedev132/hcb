# frozen_string_literal: true

module HcbCodeService
  module Comment
    class Create
      def initialize(hcb_code_id:,
                     content:, file: nil, admin_only: false,
                     current_user:)
        @hcb_code_id = hcb_code_id
        @content = content
        @file = file
        @admin_only = admin_only || false

        @current_user = current_user
      end

      def run
        hcb_code.comments.create!(attrs)
      end

      private

      def attrs
        {
          content: @content,
          file: @file,
          admin_only: @admin_only,
          user: @current_user
        }
      end

      def hcb_code
        @hcb_code ||= HcbCode.find(@hcb_code_id)
      end
    end
  end
end
