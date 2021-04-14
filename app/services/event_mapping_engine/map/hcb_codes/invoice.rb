# frozen_string_literal: true

module EventMappingEngine
  module Map
    module HcbCodes
      class Invoice
        def run
          unmapped_invoice_codes.find_each(batch_size: 100) do |ct|
            # 1 locate invoice id
            hcb_code_str = ct.memo.scan(/HCB-100-\d+/).first
            next unless hcb_code_str

            invoice_id = hcb_code_str.split("-")[2]
            invoice = ::Invoice.find_by(id: invoice_id)
            next unless invoice

            guessed_event_id = invoice.event.id

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

        def unmapped_invoice_codes
          ::CanonicalTransaction.unmapped.where("memo ilike '#{code}%'").order("date asc")
        end

        def code
          "HCKCLB HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE}-"
        end

      end
    end
  end
end
