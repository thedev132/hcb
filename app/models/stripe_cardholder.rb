# frozen_string_literal: true

# == Schema Information
#
# Table name: stripe_cardholders
#
#  id                                 :bigint           not null, primary key
#  cardholder_type                    :integer          default("individual"), not null
#  stripe_billing_address_city        :text
#  stripe_billing_address_country     :text
#  stripe_billing_address_line1       :text
#  stripe_billing_address_line2       :text
#  stripe_billing_address_postal_code :text
#  stripe_billing_address_state       :text
#  stripe_email                       :text
#  stripe_name                        :text
#  stripe_phone_number                :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  stripe_id                          :text
#  user_id                            :bigint           not null
#
# Indexes
#
#  index_stripe_cardholders_on_stripe_id  (stripe_id)
#  index_stripe_cardholders_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class StripeCardholder < ApplicationRecord
  enum cardholder_type: { individual: 0, company: 1 }

  belongs_to :user
  has_many :stripe_cards
  alias_attribute :cards, :stripe_cards
  has_many :stripe_authorizations, through: :stripe_cards
  alias_attribute :authorizations, :stripe_authorizations
  alias_attribute :transactions, :stripe_authorizations

  validates_uniqueness_of :stripe_id

  validates :stripe_billing_address_line1, presence: true, on: :update
  validates :stripe_billing_address_city, presence: true, on: :update
  validates :stripe_billing_address_country, presence: true, on: :update

  alias_attribute :address_line1, :stripe_billing_address_line1
  alias_attribute :address_line2, :stripe_billing_address_line2
  alias_attribute :address_city, :stripe_billing_address_city
  alias_attribute :address_state, :stripe_billing_address_state
  alias_attribute :address_country, :stripe_billing_address_country
  alias_attribute :address_postal_code, :stripe_billing_address_postal_code

  before_update :update_cardholder_in_stripe

  def stripe_dashboard_url
    "https://dashboard.stripe.com/issuing/cardholders/#{self.stripe_id}"
  end

  def state
    return :success if remote_status == "active"
    return :error if remote_status == "blocked"
    return :error if remote_status == "disabled"

    :muted
  end

  def state_text
    remote_status.to_s.humanize
  end

  def full_address
    [
      stripe_billing_address_line1,
      stripe_billing_address_line2,
      stripe_billing_address_city,
      stripe_billing_address_state,
      stripe_billing_address_postal_code
    ].join(" ")
  end

  def remote_status
    return "disabled" if remote_requirements_disabled_reason.present?

    stripe_obj[:status]
  end

  def remote_requirements_disabled_reason
    stripe_obj[:requirements].try(:[], :disabled_reason)
  end

  private

  def update_cardholder_in_stripe
    begin
      StripeService::Issuing::Cardholder.update(
        stripe_id,
        {
          email: stripe_email,
          phone_number: stripe_phone_number,
          billing: {
            address: {
              line1: address_line1,
              line2: address_line2,
              city: address_city,
              state: address_state,
              postal_code: address_postal_code,
              country: address_country
            }.compact_blank
          }
        }.compact_blank
      )
    rescue Stripe::StripeError # fails without proper keys
      raise if Rails.env.production?
    end
  end

  def stripe_obj
    @stripe_obj ||= StripeService::Issuing::Cardholder.retrieve(stripe_id)
  rescue => e
    Airbrake.notify(e)

    { status: "active", requirements: {} } # https://stripe.com/docs/api/issuing/cardholders/object
  end

end
