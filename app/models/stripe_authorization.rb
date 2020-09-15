class StripeAuthorization < ApplicationRecord
  before_validation :sync_from_stripe! # pull details from stripe if we're creating it for the first time
  after_create :notify_of_creation

  scope :awaiting_receipt, -> { includes(:receipts).where(approved: true, receipts: { stripe_authorization_id: nil }) } # TODO: remove reversed TXs from this list
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(stripe_status: :pending) }
  scope :declined, -> { where(stripe_status: :declined) }
  scope :successful, -> { where(stripe_status: :closed, approved: true) }
  
  has_paper_trail

  belongs_to :stripe_card, class_name: 'StripeCard'
  alias_attribute :card, :stripe_card
  has_one :stripe_cardholder, through: :stripe_card, as: :cardholder
  alias_attribute :cardholder, :stripe_cardholder
  has_one :event, through: :stripe_card
  has_many :receipts
  has_many :comments, as: :commentable

  enum stripe_status: { pending: 0, closed: 1, reversed: 2 }
  enum authorization_method: { keyed_in: 0, swipe: 1, chip: 2, contactless: 3, online: 4 }

  validates_uniqueness_of :stripe_id

  validates_presence_of :stripe_id, :stripe_status, :authorization_method, :amount

  def name
    stripe_obj[:merchant_data][:name]
  end

  def filter_data
    {
      exists: true,
      fee_applies: false,
      fee_payment: false,
      emburse: false,
      expensify: false,
    }
  end

  def status_emoji
    return '✔️' if approved?

    '✖️'
  end

  def status_text
    return 'Declined' unless approved?
    return 'Pending' if pending?
    return 'Reversed' if reversed?
    return 'Approved' if approved?

    '–'
  end

  def status_color
    return :error unless approved?
    return :muted if pending?
    return :warning if reversed?
    return :success if approved?

    :accent
  end

  def merchant_name
    stripe_obj[:merchant_data][:name]
  end

  def sync_from_stripe!
    puts "syncing from stripe"
    self.stripe_id = stripe_obj[:id]
    self.stripe_status = stripe_obj[:status]
    self.authorization_method = stripe_obj[:authorization_method]
    self.approved = stripe_obj[:approved]
    self.amount = stripe_obj[:amount]

    stripe_card_id = stripe_obj[:card][:id]
    self.stripe_card = StripeCard.find_by(stripe_id: stripe_card_id)
  end

  def stripe_obj
    @stripe_auth_obj ||= begin
      StripeService::Issuing::Authorization.retrieve(stripe_id)
    end

    @stripe_auth_obj
  end

  private

  def notify_of_creation
    # Notify the admins
    StripeAuthorizationMailer.with(auth_id: id).notify_admin_of_authorization.deliver_later

    # Notify the card user
    if approved?
      StripeAuthorizationMailer.with(auth_id: id).notify_user_of_approve.deliver_later
    else
      StripeAuthorizationMailer.with(auth_id: id).notify_user_of_decline.deliver_later
    end
  end
end
