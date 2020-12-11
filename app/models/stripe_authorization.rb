class StripeAuthorization < ApplicationRecord
  include Receiptable
  include Commentable

  before_validation :sync_from_stripe! # pull details from stripe if we're creating it for the first time
  after_create :notify_of_creation

  default_scope { order(created_at: :desc) }
  scope :awaiting_receipt, -> { missing_receipt.where.not(amount: 0).where(approved: true) }
  scope :unified_list, -> { approved.where.not(stripe_status: :reversed) }
  scope :approved, -> { where(approved: true) }
  scope :declined, -> { where(approved: false) }
  scope :successful, -> { approved.closed }

  def awaiting_receipt?
    !amount.zero? && approved && missing_receipt?
  end

  def declined?
    approved == false
  end
  
  has_paper_trail

  belongs_to :stripe_card, class_name: 'StripeCard'
  alias_attribute :card, :stripe_card
  has_one :stripe_cardholder, through: :stripe_card, as: :cardholder
  alias_attribute :cardholder, :stripe_cardholder
  has_one :event, through: :stripe_card

  enum stripe_status: { pending: 0, closed: 1, reversed: 2 }
  enum authorization_method: { keyed_in: 0, swipe: 1, chip: 2, contactless: 3, online: 4 }

  validates_uniqueness_of :stripe_id

  validates_presence_of :stripe_id, :stripe_status, :authorization_method, :amount, :name

  def user
    cardholder.user
  end

  def filter_data
    {
      exists: true,
      fee_applies: false,
      fee_payment: false,
      card: true
    }
  end

  def status_emoji
    return '✔️' if approved?

    '✖️'
  end

  def status_text
    return 'Declined' unless approved?
    return 'Pending' if pending?
    return 'Refunded' if reversed?
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

  def authorization_method_text
    (stripe_obj[:wallet] || authorization_method).humanize
  end

  def merchant_name
    @merchant_name ||= name || stripe_obj[:merchant_data][:name]
  end

  def merchant_data
    @merchant_data ||= stripe_obj[:merchant_data]
  end

  def sync_from_stripe!
    puts "syncing from stripe"
    self.stripe_id = stripe_obj[:id]
    self.stripe_status = stripe_obj[:status]
    self.authorization_method = stripe_obj[:authorization_method]
    self.approved = stripe_obj[:approved]
    self.amount = stripe_obj[:amount]
    self.name = stripe_obj[:merchant_data][:name]

    stripe_card_id = stripe_obj[:card][:id]
    self.stripe_card = StripeCard.find_by(stripe_id: stripe_card_id)

    # (max@maxwofford.com) https://github.com/hackclub/bank/issues/1031
    # This is a chaotic way of solving #1031 (tl;dr, stripe doesn't
    # consistently tell us if a tx was refunded). We're going to deviate from
    # the status stripe is telling us and mark it as 'refunded' if all the
    # authorization's transactions sum to 0.
    if (stripe_obj[:status] == 'closed' && stripe_obj[:transactions].size > 1)
      net_amount = -stripe_obj[:transactions].pluck(:amount).sum # must be negated since the rest of stripe_authorizations is treating positives as negatives in the interface
      self.amount = net_amount
      self.stripe_status = 'reversed' if net_amount.zero?
    end
  end

  def stripe_obj
    @stripe_auth_obj ||= begin
      StripeService::Issuing::Authorization.retrieve(stripe_id)
    end

    @stripe_auth_obj
  end

  def remote_stripe_transaction_amount_cents
    @remote_stripe_transaction_amount_cents ||= remote_stripe_transactions.map(&:amount).sum
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

  def remote_stripe_transactions
    @remote_stripe_transactions ||= begin
      remote_stripe_authorization['transactions'].map do |t|
        ::Partners::Stripe::Issuing::Transactions::Show.new(id: t.id).run
      end
    end
  end

  def remote_stripe_authorization
    @remote_stripe_authorization ||= ::Partners::Stripe::Issuing::Authorizations::Show.new(id: stripe_id).run
  end
end
