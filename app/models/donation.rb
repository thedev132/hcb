# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                                   :bigint           not null, primary key
#  aasm_state                           :string
#  amount                               :integer
#  amount_received                      :integer
#  email                                :text
#  hcb_code                             :text
#  message                              :text
#  name                                 :text
#  payout_creation_balance_available_at :datetime
#  payout_creation_balance_net          :integer
#  payout_creation_balance_stripe_fee   :integer
#  payout_creation_queued_at            :datetime
#  payout_creation_queued_for           :datetime
#  status                               :string
#  stripe_client_secret                 :string
#  url_hash                             :string
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  event_id                             :bigint
#  fee_reimbursement_id                 :bigint
#  payout_creation_queued_job_id        :string
#  payout_id                            :bigint
#  recurring_donation_id                :bigint
#  stripe_payment_intent_id             :string
#
# Indexes
#
#  index_donations_on_event_id               (event_id)
#  index_donations_on_fee_reimbursement_id   (fee_reimbursement_id)
#  index_donations_on_payout_id              (payout_id)
#  index_donations_on_recurring_donation_id  (recurring_donation_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (fee_reimbursement_id => fee_reimbursements.id)
#  fk_rails_...  (payout_id => donation_payouts.id)
#
class Donation < ApplicationRecord
  has_paper_trail

  include PublicIdentifiable
  set_public_id_prefix :don

  include AASM
  include Commentable

  include PgSearch::Model
  pg_search_scope :search_name, against: [:name, :email], using: { tsearch: { prefix: true, dictionary: "english" } }, ranked_by: "donations.created_at"

  belongs_to :event
  belongs_to :fee_reimbursement, required: false
  belongs_to :payout, class_name: "DonationPayout", required: false
  belongs_to :recurring_donation, required: false

  before_create :create_stripe_payment_intent, unless: -> { recurring? }
  before_create :assign_unique_hash, unless: -> { recurring? }

  after_update :send_payment_notification_if_needed

  validates :name, :email, presence: true, unless: -> { recurring? } # recurring donations have a name/email in their `RecurringDonation` object
  validates_presence_of :amount
  validates :amount, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 999_999_99 }

  scope :succeeded, -> { where(status: "succeeded") }
  scope :missing_payout, -> { where(payout_id: nil) }
  scope :missing_fee_reimbursement, -> { where(fee_reimbursement_id: nil) }
  scope :not_pending, -> { where.not(aasm_state: "pending") }
  scope :incoming_deposits, -> { where("aasm_state in (?)", ["in_transit"]) }

  aasm do
    state :pending, initial: true
    state :in_transit
    state :deposited
    state :failed
    state :refunded

    event :mark_in_transit do
      transitions from: :pending, to: :in_transit
    end

    event :mark_deposited do
      transitions from: :in_transit, to: :deposited
    end

    event :mark_refunded do
      transitions from: [:in_transit, :deposited], to: :refunded
    end

    event :mark_failed do
      transitions from: [:pending, :in_transit], to: :failed
    end
  end

  def set_fields_from_stripe_payment_intent(payment_intent)
    self.amount = payment_intent.amount
    self.amount_received = payment_intent.amount_received
    self.status = payment_intent.status
    self.stripe_client_secret = payment_intent.client_secret

    self.aasm_state = "in_transit" if aasm_state == "pending" && status == "succeeded" # hacky
  end

  def stripe_dashboard_url
    "https://dashboard.stripe.com/payments/#{self.stripe_payment_intent_id}"
  end

  def state
    return :success if deposited?
    return :success if in_transit? && event.can_front_balance?
    return :info if in_transit?
    return :warning if refunded?
    return :error if failed?

    :muted
  end

  def state_text
    return "Deposited" if deposited?
    return "Deposited" if in_transit? && event.can_front_balance?
    return "In Transit" if in_transit?
    return "Refunded" if refunded?
    return "Failed" if failed?

    "Pending"
  end

  def state_icon
    return "checkmark" if deposited? || (in_transit? && event.can_front_balance?)

    "clock" if in_transit?
  end

  def unpaid?
    pending?
  end

  def filter_data
    {
      in_transit: in_transit?,
      deposited: deposited?,
      exists: true
    }
  end

  def send_receipt!
    DonationMailer.with(donation: self).donor_receipt.deliver_later
  end

  def arrival_date
    arrival = self&.payout&.arrival_date || 3.business_days.after(payout_creation_queued_for)

    # Add 1 day to account for plaid and Bank processing time
    arrival + 1.day
  end

  def arriving_late?
    DateTime.now > self.arrival_date
  end

  def payment_method_type
    stripe_obj.dig(:payment_method, :type)
  end

  def payment_method_card_brand
    stripe_obj.dig(:payment_method, :card, :brand)
  end

  def payment_method_card_last4
    stripe_obj.dig(:payment_method, :card, :last4)
  end

  def payment_method_card_funding
    stripe_obj.dig(:payment_method, :card, :funding)
  end

  def payment_method_card_exp_month
    stripe_obj.dig(:payment_method, :card, :exp_month)
  end

  def payment_method_card_exp_year
    stripe_obj.dig(:payment_method, :card, :exp_year)
  end

  def payment_method_card_country
    stripe_obj.dig(:payment_method, :card, :country)
  end

  def payment_method_card_checks_address_line1_check
    stripe_obj.dig(:payment_method, :card, :checks, :address_line1_check)
  end

  def payment_method_card_checks_address_postal_code_check
    stripe_obj.dig(:payment_method, :card, :checks, :address_postal_code_check)
  end

  def payment_method_card_checks_cvc_check
    stripe_obj.dig(:payment_method, :card, :checks, :cvc_check)
  end

  def stripe_obj
    @stripe_donation_obj ||=
      StripeService::PaymentIntent.retrieve(id: stripe_payment_intent_id, expand: ["payment_method"]).to_hash
  rescue => e
    {}
  end

  def smart_memo
    name.to_s.upcase
  end

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::DONATION_CODE}-#{id}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end

  def canonical_pending_transaction
    canonical_pending_transactions.first
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code:)
  end

  def canonical_pending_transactions
    @canonical_pending_transactions ||= begin
      return [] unless raw_pending_donation_transaction.present?

      ::CanonicalPendingTransaction.where(raw_pending_donation_transaction_id: raw_pending_donation_transaction.id)
    end
  end

  def remote_donation
    @remote_donation ||= ::Partners::Stripe::PaymentIntents::Show.new(id: stripe_payment_intent_id).run
  end

  def remote_refunded?
    remote_donation[:charges][:data][0][:refunded]
  end

  def amount_settled
    canonical_transactions.sum(:amount_cents)
  end

  def fee_reimbursed?
    fee_reimbursement.canonical_transaction.present?
  end

  def recurring?
    recurring_donation.present?
  end

  def initial_recurring_donation?
    recurring? && recurring_donation.donations.order(created_at: :asc).first == self
  end

  def name
    recurring_donation&.name || super
  end

  def email
    recurring_donation&.email || super
  end

  private

  def raw_pending_donation_transaction
    raw_pending_donation_transactions.first
  end

  def raw_pending_donation_transactions
    @raw_pending_donation_transactions ||= ::RawPendingDonationTransaction.where(donation_transaction_id: id)
  end

  def send_payment_notification_if_needed
    return unless saved_changes[:status].present?

    return unless status_changed_to_succeeded?(saved_changes[:status])
    return unless first_donation?

    DonationMailer.with(donation: self).first_donation_notification.deliver_later
  end

  def status_changed_to_succeeded?(saved_changes)
    was, now = saved_changes

    was != "succeeded" && now == "succeeded"
  end

  def first_donation?
    self.event.donations.succeeded.size == 1
  end

  def create_payment_intent_attrs
    {
      amount:,
      currency: "usd",
      statement_descriptor: "HACK CLUB BANK",
      statement_descriptor_suffix: StripeService::StatementDescriptor.format(event.name, as: :suffix),
      metadata: { 'donation': true, 'event_id': event.id }
    }
  end

  def create_stripe_payment_intent
    payment_intent = StripeService::PaymentIntent.create(create_payment_intent_attrs)

    self.stripe_payment_intent_id = payment_intent.id

    self.set_fields_from_stripe_payment_intent(payment_intent)
  end

  def assign_unique_hash
    self.url_hash = SecureRandom.hex(8)
  end

end
