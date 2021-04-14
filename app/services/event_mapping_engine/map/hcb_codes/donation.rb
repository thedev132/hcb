# frozen_string_literal: true

module EventMappingEngine
  module Map
    module HcbCodes
      class Donation
        def run
          unmapped_donation_codes.find_each(batch_size: 100) do |ct|
            # 1 locate donation id
            hcb_code_str = ct.memo.scan(/HCB-200-\d+/).first
            next unless hcb_code_str

            donation_id = hcb_code_str.split("-")[2]
            donation = ::Donation.find_by(id: donation_id)
            next unless donation

            guessed_event_id = donation.event.id

            ActiveRecord::Base.transaction do
              ct.update_column(:hcb_code, hcb_code_str)

              attrs = {
                canonical_transaction_id: ct.id,
                event_id: guessed_event_id
              }
              ::CanonicalEventMapping.create!(attrs)
            end
          end
        end

        private

        def unmapped_donation_codes
          ::CanonicalTransaction.unmapped.where("memo ilike '#{code}%'").order("date asc")
        end

        def code
          "HCKCLB HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE}-"
        end

      end
    end
  end
end
