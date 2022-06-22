# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_pending_stripe_transactions
#
#  id                    :bigint           not null, primary key
#  amount_cents          :integer
#  date_posted           :date
#  stripe_transaction    :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_transaction_id :text
#
class RawPendingStripeTransaction < ApplicationRecord
  monetize :amount_cents

  scope :reversed, -> { where("stripe_transaction->>'status' = 'reversed'") }

  def date
    date_posted
  end

  def memo
    stripe_transaction.dig("merchant_data", "name")
  end

  def likely_event_id
    @likely_event_id ||= ::StripeCard.find_by!(stripe_id: stripe_card_id).event_id
  end

  def stripe_card
    @stripe_card ||= StripeCard.find_by(stripe_id: stripe_card_id)
  end

  def authorization_method
    stripe_transaction.dig("authorization_method").humanize.downcase
  end

  private

  def stripe_card_id
    stripe_transaction.dig("card", "id")
  end

end
