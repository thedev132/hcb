class StripeCard < ApplicationRecord
  before_create :issue_stripe_card, unless: :issued? # issue the card if we're creating it for the first time
  after_create :notify_user, :pay_for_issuing

  scope :deactivated, -> { where.not(stripe_status: 'active') }
  scope :active, -> { where(stripe_status: 'active') }
  scope :physical_shipping, -> { physical.includes(:user, :event).select { |c| c.stripe_obj[:shipping][:status] != 'delivered' } }

  belongs_to :event
  belongs_to :stripe_cardholder
  alias_attribute :cardholder, :stripe_cardholder
  has_one :user, through: :stripe_cardholder
  has_many :stripe_authorizations
  alias_attribute :authorizations, :stripe_authorizations
  alias_attribute :transactions, :stripe_authorizations

  alias_attribute :last_four, :last4

  enum card_type: { virtual: 0, physical: 1 }

  validates_uniqueness_of :stripe_id

  validates_presence_of :stripe_shipping_address_city,
                        :stripe_shipping_address_country,
                        :stripe_shipping_address_line1,
                        # :stripe_shipping_address_line2, # optional
                        # :stripe_shipping_address_state, # optional
                        :stripe_shipping_address_postal_code,
                        :stripe_shipping_name,
                        unless: -> { self.virtual? }

  validates_presence_of :stripe_cardholder_id,
                        :card_type,
                        :stripe_id,
                        :stripe_brand,
                        :stripe_exp_month,
                        :stripe_exp_year,
                        :last4,
                        :stripe_status,
                        if: -> { self.stripe_id.present? }

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
    stripe_cardholder.stripe_name
  end

  def total_spent
    stripe_authorizations.approved.sum(:amount)
  end

  def status_text
    stripe_status.humanize.capitalize
  end

  def status_badge_type
    s = stripe_status.to_sym
    return :success if s == :active
    return :error if s == :deleted

    :muted
  end

  def stripe_dashboard_url
    "https://dashboard.stripe.com/issuing/cards/#{self.stripe_id}"
  end

  def freeze!
    StripeService::Issuing::Card.update(self.stripe_id, status: :inactive)
    sync_from_stripe!
    save!
  end

  def defrost!
    StripeService::Issuing::Card.update(self.stripe_id, status: :active)
    sync_from_stripe!
    save!
  end

  def deactivated?
    stripe_status != 'active'
  end

  include ActiveModel::AttributeMethods
  alias_attribute :address_line1, :stripe_shipping_address_line1
  alias_attribute :address_line2, :stripe_shipping_address_line2
  alias_attribute :address_city, :stripe_shipping_address_city
  alias_attribute :address_state, :stripe_shipping_address_state
  alias_attribute :address_country, :stripe_shipping_address_country
  alias_attribute :address_postal_code, :stripe_shipping_address_postal_code

  def stripe_obj
    @stripe_card_obj ||= begin
      StripeService::Issuing::Card.retrieve(stripe_id)
    end

    @stripe_card_obj
  end

  def shipping_has_tracking?
    stripe_obj[:shipping][:tracking_number].present?
  end

  def self.new_from_stripe_id(params)
    raise ArgumentError.new("Only numbers are allowed") unless params[:stripe_id].is_a?(String)

    card = self.new(params)
    card.sync_from_stripe!

    card
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

  def issuing_cost
    # (@msw) Stripe's API doesn't provide issuing + shipping costs, so this
    # method computes the cost of issuing a card based on Stripe's
    # docs:
    # https://stripe.com/docs/issuing/cards/physical#costs
    # https://stripe.com/docs/issuing/cards/virtual#costs

    # *all amounts in cents*

    return 10 if virtual?

    cost = 300
    cost_type = stripe_obj['shipping']['type'] + '|' + stripe_obj['shipping']['service']
    case cost_type
    when 'individual|standard'
      cost += 50
    when 'individual|express'
      cost += 1600
    when 'individual|priority'
      cost += 2200
    when 'bulk|standard'
      cost += 2500
    when 'bulk|express'
      cost += 3000
    when 'bulk|priority'
      cost += 4800
    end

    cost
  end

  private

  def issued?
    !stripe_id.blank?
  end

  def secret_details
    # (msw) We do not want to store card info in our database, so this private
    # method is the only way to get this info
    @secret_details ||= StripeService::Issuing::Card.details(stripe_id)

    @secret_details
  end

  def pay_for_issuing
    PayForIssuedCardJob.perform_later(self)
  end

  def notify_user
    if virtual?
      StripeCardMailer.with(card_id: self.id).virtual_card_ordered.deliver_later
    else
      StripeCardMailer.with(card_id: self.id).physical_card_ordered.deliver_later
    end
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
      card_options[:shipping] = {}
      card_options[:shipping][:name] = stripe_shipping_name
      card_options[:shipping][:service] = 'standard'
      card_options[:shipping][:address] = {
        city: stripe_shipping_address_city,
        country: 'US', # This is hard-coded for now because Stripe doesn't support card issuing for other countries yet
        line1: stripe_shipping_address_line1,
        postal_code: stripe_shipping_address_postal_code
      }
      card_options[:shipping][:address][:line2] = stripe_shipping_address_line2 unless stripe_shipping_address_line2.blank?
      card_options[:shipping][:address][:state] = stripe_shipping_address_state unless stripe_shipping_address_state.blank?
    end

    card = StripeService::Issuing::Card.create(card_options)

    @stripe_card_obj = card
    sync_from_stripe!
  end

  def authorizations_from_stripe
    @auths ||= begin
      result = []
      auths = StripeService::Issuing::Authorization.list(card: stripe_id)
      auths.auto_paging_each {|auth| result << auth}
      result
    end

    @auths
  end

  def sync_authorizations
    authorizations_from_stripe.each do |stripe_auth|
      sa = StripeAuthorization.find_or_initialize_by(stripe_id: stripe_auth[:id])
      sa.sync_from_stripe!
      sa.save
    end
  end
end
