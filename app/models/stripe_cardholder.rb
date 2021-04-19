class StripeCardholder < ApplicationRecord
  after_initialize :default_values
  before_create :issue_cardholder_profile

  enum cardholder_type: { individual: 0, company: 1 }

  belongs_to :user
  has_many :stripe_cards
  alias_attribute :cards, :stripe_cards
  has_many :stripe_authorizations, through: :stripe_cards
  alias_attribute :authorizations, :stripe_authorizations
  alias_attribute :transactions, :stripe_authorizations

  validates_uniqueness_of :stripe_id

  # validates_presence_of :stripe_id,
  #                       :stripe_billing_address_line1,
  #                       # :stripe_billing_address_line2,
  #                       :stripe_billing_address_city,
  #                       :stripe_billing_address_country,
  #                       :stripe_billing_address_postal_code,
  #                       # :stripe_billing_address_state,
  #                       :stripe_name,
  #                       :stripe_email,
  #                       :stripe_phone_number

  alias_attribute :address_line1, :stripe_billing_address_line1
  alias_attribute :address_line2, :stripe_billing_address_line2
  alias_attribute :address_city, :stripe_billing_address_city
  alias_attribute :address_state, :stripe_billing_address_state
  alias_attribute :address_country, :stripe_billing_address_country
  alias_attribute :address_postal_code, :stripe_billing_address_postal_code

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

  def default_values
    self.address_line1 ||= "8605 Santa Monica Blvd #86294"
    self.address_city ||= "West Hollywood"
    self.address_state ||= "CA"
    self.address_postal_code ||= "90069"
    self.address_country ||= "US"
  end

  def issue_cardholder_profile
    address = {
      line1: stripe_billing_address_line1,
      line2: stripe_billing_address_line2,
      city: stripe_billing_address_city,
      state: stripe_billing_address_state,
      postal_code: stripe_billing_address_postal_code,
      country: stripe_billing_address_country,
    }
    address.delete(:line2) if stripe_billing_address_line2 == ""
    address.delete(:state) if stripe_billing_address_state == ""
    cardholder = StripeService::Issuing::Cardholder.create(
      name: user.safe_name,
      email: user.email,
      phone_number: user.phone_number,
      type: cardholder_type,
      billing: {
        address: address
      }
    )

    @stripe_cardholder_obj = cardholder

    sync_from_stripe!

    self
  end

  def sync_from_stripe!
    self.stripe_id = stripe_obj[:id]
    self.stripe_billing_address_line1 = stripe_obj[:billing][:address][:line1]
    self.stripe_billing_address_line2 = stripe_obj[:billing][:address][:line2]
    self.stripe_billing_address_city = stripe_obj[:billing][:address][:city]
    self.stripe_billing_address_country = stripe_obj[:billing][:address][:country]
    self.stripe_billing_address_postal_code = stripe_obj[:billing][:address][:postal_code]
    self.stripe_billing_address_state = stripe_obj[:billing][:address][:state]
    self.stripe_name = stripe_obj[:billing][:name]
    self.stripe_email = stripe_obj[:email]
    self.stripe_phone_number = stripe_obj[:phone_number]
    self.cardholder_type = stripe_obj[:type]

    self
  end

  def stripe_obj
    @stripe_obj ||= StripeService::Issuing::Cardholder.retrieve(stripe_id)
  rescue => e
    Airbrake.notify(e)

    { status: "active", requirements: { } } # https://stripe.com/docs/api/issuing/cardholders/object
  end
end
