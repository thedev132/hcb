class StripeCard < ApplicationRecord
  before_create :issue_stripe_card # issue the card if we're creating it for the first time

  belongs_to :event
  belongs_to :stripe_cardholder
  has_one :user, through: :stripe_cardholder

  enum card_type: { virtual: 0, plastic: 1 }

  validates_presence_of :stripe_shipping_address_city,
                        :stripe_shipping_address_country,
                        :stripe_shipping_address_line1,
                        # :stripe_shipping_address_line2, # optional
                        # :stripe_shipping_address_state, # optional
                        :stripe_shipping_address_postal_code,
                        :stripe_shipping_name,
                        unless: -> { self.virtual? }

  validates_presence_of :cardholder_id,
                        :card_type,
                        :stripe_id,
                        :stripe_brand,
                        :stripe_exp_month,
                        :stripe_exp_year,
                        :last4,
                        :stripe_status,
                        if: -> { self.stripe_id.present? }

  def active?
    stripe_status == 'active'
  end

  def full_card_number
    secret_details[:number]
  end

  def cvc
    secret_details[:cvc]
  end

  def formatted_card_number
    return "•••• •••• •••• #{last4}" unless virtual?
    full_card_number.scan(/.{4}/).join(' ')
  end

  def hidden_card_number
    "•••• •••• •••• ••••"
  end

  def stripe_name
    self.stripe_cardholder.stripe_name
  end

  private

  def secret_details
    # (msw) We do not want to store card info in our database, so this private
    # method is the only way to get this info
    @secret_details ||= Stripe::Issuing::Card.details(stripe_id)

    @secret_details
  end

  def sync_from_stripe!
    if stripe_obj[:deleted]
      self.stripe_status = 'deleted'
      return self
    end
    self.stripe_id = stripe_obj[:id]
    self.stripe_brand = stripe_obj[:brand]
    self.stripe_exp_month = stripe_obj[:exp_month]
    self.stripe_exp_year = stripe_obj[:exp_year]
    self.last4 = stripe_obj[:last4]
    self.stripe_status = stripe_obj[:status]
    self.card_type = stripe_obj[:type]
    if stripe_obj[:shipping]
      self.stripe_shipping_address_city = stripe_obj[:shipping][:address][:city]
      self.stripe_shipping_address_country = stripe_obj[:shipping][:address][:country]
      self.stripe_shipping_address_line1 = stripe_obj[:shipping][:address][:line1]
      self.stripe_shipping_address_postal_code = stripe_obj[:shipping][:address][:postal_code]
      self.stripe_shipping_address_line2 = stripe_obj[:shipping][:address][:line2]
      self.stripe_shipping_address_state = stripe_obj[:shipping][:address][:state]
      self.stripe_shipping_name = stripe_obj[:shipping][:name]
    end

    self
  end

  def issue_stripe_card
    return self if persisted?

    card_options = {
      cardholder: stripe_cardholder.stripe_id,
      type: card_type,
      currency: 'usd',
      status: 'active'
    }

    unless virtual?
      card_options[:shipping][:name] = stripe_shipping_name
      card_options[:shipping][:address] = {
        city: stripe_shipping_address_city,
        country: stripe_shipping_address_country,
        line1: stripe_shipping_address_line1,
        line2: stripe_shipping_address_line2,
        postal_code: stripe_shipping_address_postal_code,
        state: stripe_shipping_address_state
      }
      card_options[:shipping][:address].delete(state) if stripe_shipping_address_state.nil?
      card_options[:shipping][:address].delete(line2) if stripe_shipping_address_line2.nil?
    end

    card = StripeService::Issuing::Card.create(card_options)

    @stripe_card_obj = card
    sync_from_stripe!
  end

  def stripe_obj
    @stripe_card_obj ||= begin
      StripeService::Issuing::Card.retrieve(stripe_id)
    end

    @stripe_card_obj
  end
end
