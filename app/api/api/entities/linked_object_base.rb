# frozen_string_literal: true

module Api
  module Entities
    class LinkedObjectBase < Base
      API_LINKED_OBJECT_TYPE = "linked_objects"

      when_expanded do
        expose :memo do |obj, options|
          obj.local_hcb_code.memo
        end
      end

      when_showing(Transaction) do
        expose :transaction, documentation: { type: Transaction } do |obj, options|
          Entities::Transaction.represent(obj.local_hcb_code, options_hide(API_LINKED_OBJECT_TYPE))
        end
      end

      when_showing Organization do
        expose :organization, documentation: { type: Organization } do |obj, options|
          Organization.represent(obj.event, options_hide(User))
        end
      end

    end
  end
end
