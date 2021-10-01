# frozen_string_literal: true

class StripeCard < ApplicationRecord
  after_create_commit :notify_user, :pay_for_issuing

  scope :deactivated, -> { where.not(stripe_status: "active") }
  scope :canceled, -> { where(stripe_status: "canceled") }
  scope :frozen, -> { where(stripe_status: "inactive") }
  scope :active, -> { where(stripe_status: "active") }
  scope :physical_shipping, -> { physical.includes(:user, :event).select { |c| c.stripe_obj[:shipping][:status] != "delivered" } }

  belongs_to :event
  belongs_to :stripe_cardholder
  alias_attribute :cardholder, :stripe_cardholder
  has_one :user, through: :stripe_cardholder
  has_many :stripe_authorizations
  alias_attribute :authorizations, :stripe_authorizations
  alias_attribute :transactions, :stripe_authorizations

  alias_attribute :last_four, :last4

  enum card_type: { virtual: 0, physical: 1 }
  enum spending_limit_interval: { daily: 0, weekly: 1, monthly: 2 }

  validates_uniqueness_of :stripe_id

  validates_presence_of :stripe_shipping_address_city,
                        :stripe_shipping_address_country,
                        :stripe_shipping_address_line1,
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
    full_card_number.scan(/.{4}/).join(" ")
  end

  def hidden_card_number
    "•••• •••• •••• ••••"
  end

  def stripe_name
    stripe_cardholder.stripe_name
  end

  def name
    stripe_name
  end

  def total_spent
    stripe_authorizations.approved.sum(:amount)
  end

  def status_text
    return "frozen" if stripe_status == "inactive"
    stripe_status.humanize
  end

  def state_text
    status_text
  end

  def status_badge_type
    s = stripe_status.to_sym
    return :success if s == :active
    return :error if s == :deleted

    :muted
  end

  def state
    status_badge_type
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

  def frozen?
    stripe_status == "inactive"
  end

  def deactivated?
    stripe_status != "active"
  end

  def canceled?
    stripe_status == "canceled"
  end

  include ActiveModel::AttributeMethods
  alias_attribute :address_line1, :stripe_shipping_address_line1
  alias_attribute :address_line2, :stripe_shipping_address_line2
  alias_attribute :address_city, :stripe_shipping_address_city
  alias_attribute :address_state, :stripe_shipping_address_state
  alias_attribute :address_country, :stripe_shipping_address_country
  alias_attribute :address_postal_code, :stripe_shipping_address_postal_code

  def stripe_obj
    @stripe_obj ||= ::Partners::Stripe::Issuing::Cards::Show.new(id: stripe_id).run
  rescue => e
    { number: "XXXX", cvc: "XXX", created: Time.now.utc.to_i, shipping: { status: "delivered" } }
  end

  def secret_details
    @secret_details ||= ::Partners::Stripe::Issuing::Cards::Show.new(id: stripe_id, expand: ["cvc", "number"]).run
  rescue => e
    { number: "XXXX", cvc: "XXX" }
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
      self.stripe_status = "deleted"
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

    spending_limits = stripe_obj[:spending_controls][:spending_limits]
    if spending_limits.any?
      self.spending_limit_interval = spending_limits.first[:interval]
      self.spending_limit_amount = spending_limits.first[:amount]
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
    cost_type = stripe_obj["shipping"]["type"] + "|" + stripe_obj["shipping"]["service"]
    case cost_type
    when "individual|standard"
      cost += 50
    when "individual|express"
      cost += 1600
    when "individual|priority"
      cost += 2200
    when "bulk|standard"
      cost += 2500
    when "bulk|express"
      cost += 3000
    when "bulk|priority"
      cost += 4800
    end

    cost
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(id: canonical_transaction_ids)
  end

  def hcb_codes
    @hcb_codes ||= ::HcbCode.where(hcb_code: canonical_transaction_hcb_codes)
  end

  def remote_shipping_status
    return nil if virtual?

    stripe_obj[:shipping][:status]
  end

  private

  def canonical_transaction_hcb_codes
    @canonical_transaction_hcb_codes ||= canonical_transactions.pluck(:hcb_code)
  end

  def canonical_transaction_ids
    @canonical_transaction_ids ||= CanonicalHashedMapping.where(hashed_transaction_id: hashed_transaction_ids).pluck(:canonical_transaction_id)
  end

  def hashed_transaction_ids
    @hashed_transaction_ids ||= HashedTransaction.where(raw_stripe_transaction_id: raw_stripe_transaction_ids).pluck(:id)
  end

  def raw_stripe_transaction_ids
    @raw_stripe_transaction_ids ||= RawStripeTransaction.where("stripe_transaction->>'card' = ?", stripe_id).pluck(:id)
  end

  def issued?
    !stripe_id.blank?
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

  def authorizations_from_stripe
    @auths ||= begin
      result = []
      auths = StripeService::Issuing::Authorization.list(card: stripe_id)
      auths.auto_paging_each { |auth| result << auth }
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
