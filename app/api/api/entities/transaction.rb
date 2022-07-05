# frozen_string_literal: true

module Api
  module Entities
    class Transaction < Base
      LINKED_OBJECT_TYPES = %w[
        invoice
        donation
        ach_transfer
        check
        transfer
        bank_account_transaction
      ].freeze

      when_expanded do
        expose :amount_cents, documentation: { type: "integer" } do |hcb_code, options|
          # By default, linked objects use the HcbCode#amount_cents method.
          # However, for Disbursements, this will always result in an
          # amount_cents of 0 (zero) since there are two equal, by opposite,
          # Canonical Transactions. Therefore, for the API, we are overriding the
          # default amount_cents exposure defined in the LinkedObjectBase.k0jjkk
          next hcb_code.disbursement.amount if hcb_code.disbursement?

          hcb_code.amount_cents
        end
        expose :memo
        format_as_date do
          expose :date
        end

        expose :organization_id do |hcb_code|
          hcb_code.event.public_id
        end

        # This uses the `linked_object_type` method defined below
        expose :linked_object_type, as: :type, documentation: {
          values: LINKED_OBJECT_TYPES
        }
        expose :pending, documentation: { type: "boolean" } do |hcb_code, options|
          hcb_code.canonical_transactions.empty?
        end
      end

      when_showing(LinkedObjectBase::API_LINKED_OBJECT_TYPE) do
        [
          {
            entity: Entities::AchTransfer,
            hcb_method: :ach_transfer
          },
          {
            entity: Entities::Check,
            hcb_method: :check
          },
          {
            entity: Entities::Donation,
            hcb_method: :donation
          },
          {
            entity: Entities::Invoice,
            hcb_method: :invoice
          },
          {
            entity: Entities::Transfer,
            hcb_method: :disbursement
          },
        ].each do |linked_type|
          entity = linked_type[:entity]
          method = linked_type[:hcb_method]
          type = entity.object_type

          expose type, if: ->(hcb_code, options) {
            obj_type = linked_object_type(hcb_code.type).to_s
            self.class.should_show?(entity) && type == obj_type
          }, documentation: {
            type: entity
          } do |hcb_code, options|
            linked_objects = hcb_code.public_send(method)
            entity.represent(linked_objects, options_hide(self))
          end

        end
      end

      protected

      def linked_object_type(type = object.type)
        # some of the symbols returned by `object.type` needs to be transformed
        # to match the public representation of linked object types defined by
        # the constant LINKED_OBJECT_TYPES
        case type
        when :ach # rename "ach" to "ach_transfer"
          :ach_transfer
        when :disbursement # rename "disbursement" to "transfer"
          :transfer
        when :unknown # rename "unknown" to "bank_account_transaction"
          :bank_account_transaction
        else
          type
        end
      end

    end
  end
end
