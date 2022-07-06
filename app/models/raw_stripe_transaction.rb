# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_stripe_transactions
#
#  id                      :bigint           not null, primary key
#  amount_cents            :integer
#  date_posted             :date
#  stripe_transaction      :jsonb
#  unique_bank_identifier  :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  stripe_authorization_id :text
#  stripe_transaction_id   :text
#
# Indexes
#
#  index_raw_stripe_transactions_on_card_id_text  ((((stripe_transaction -> 'card'::text) ->> 'id'::text))) USING hash
#
class RawStripeTransaction < ApplicationRecord
  has_many :hashed_transactions

  def memo
    @memo ||= stripe_transaction.dig("merchant_data", "name")
  end

  def likely_event_id
    @likely_event_id ||= ::StripeCard.find_by!(stripe_id: stripe_card_id).event_id
  end

  private

  def stripe_card_id
    stripe_transaction.dig("card")
  end

end
