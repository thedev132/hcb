# frozen_string_literal: true

# == Schema Information
#
# Table name: user_payout_method_checks
#
#  id                  :bigint           not null, primary key
#  address_city        :text             not null
#  address_country     :text             not null
#  address_line1       :text             not null
#  address_line2       :text
#  address_postal_code :text             not null
#  address_state       :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class User
  module PayoutMethod
    class Check < ApplicationRecord
      self.table_name = "user_payout_method_checks"
      has_one :user, as: :payment_method
      validates_presence_of :address_line1, :address_city, :address_postal_code
      validates_presence_of :address_state, message: "Please select a state!"
      validates :address_state, inclusion: { in: ISO3166::Country["US"].states.keys, message: "This isn't a valid US state!", allow_blank: true }
      validates :address_postal_code, format: { with: /\A\d{5}(?:[-\s]\d{4})?\z/, message: "This isn't a valid ZIP code." }
      attribute :address_country, :text, default: "US"
      def kind
        "check"
      end

      def icon
        "email"
      end

    end
  end

end
