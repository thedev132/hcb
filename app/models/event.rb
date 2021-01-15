class Event < ApplicationRecord
  extend FriendlyId

  default_scope { order(id: :asc) }
  scope :v1, -> { where(transaction_engine_v2_at: nil) }
  scope :v2, -> { where.not(transaction_engine_v2_at: nil) }
  scope :hidden, -> { where.not(hidden_at: nil) }
  scope :not_hidden, -> { where(hidden_at: nil) }
  scope :event_ids_with_pending_fees_greater_than_100, -> do
    query = <<~SQL
      ;select event_id, fee_balance from (
        select q1.event_id, COALESCE(q1.sum, 0) as total_fees, COALESCE(q2.sum, 0) as total_fee_payments, COALESCE(q1.sum, 0) + COALESCE(q2.sum, 0) as fee_balance from (

        -- step 1: calculate total_fees per event
        select fr.event_id, sum(fr.fee_amount) from fee_relationships fr
        inner join transactions t on t.fee_relationship_id = fr.id
        inner join events e on e.id = fr.event_id
        where fr.fee_applies is true and t.deleted_at is null and e.transaction_engine_v2_at is null
        group by fr.event_id

        ) q1 

        left outer join (
        -- step 2: calculate total_fee_payments per event
        select fr.event_id, sum(t.amount) from fee_relationships fr
        inner join transactions t on t.fee_relationship_id = fr.id
        inner join events e on e.id = fr.event_id
        where fr.is_fee_payment is true and t.deleted_at is null and e.transaction_engine_v2_at is null
        group by fr.event_id
        ) q2

        on q1.event_id = q2.event_id
      ) q3
      where fee_balance > 100
    SQL

    ActiveRecord::Base.connection.execute(query)
  end

  scope :pending_fees, -> do
    where("(last_fee_processed_at is null or last_fee_processed_at <= ?) and id in (?)", 20.days.ago, self.event_ids_with_pending_fees_greater_than_100.to_a.map {|a| a["event_id"] })
  end

  scope :event_ids_with_pending_fees_greater_than_0_v2, -> do
    query = <<~SQL
      ;select event_id, fee_balance from (
      select 
      q1.event_id,
      COALESCE(q1.sum, 0) as total_fees, 
      COALESCE(q2.sum, 0) as total_fee_payments,
      COALESCE(q1.sum, 0) + COALESCE(q2.sum, 0) as fee_balance 

      from (
          select 
          cem.event_id, 
          COALESCE(sum(f.amount_cents_as_decimal), 0) as sum
          from canonical_event_mappings cem
          inner join fees f on cem.id = f.canonical_event_mapping_id
          inner join events e on e.id = cem.event_id
          where e.transaction_engine_v2_at is not null
          group by cem.event_id
      ) as q1 left outer join (
          select 
          cem.event_id, 
          COALESCE(sum(ct.amount_cents), 0) as sum
          from canonical_event_mappings cem
          inner join fees f on cem.id = f.canonical_event_mapping_id
          inner join canonical_transactions ct on cem.canonical_transaction_id = ct.id
          inner join events e on e.id = cem.event_id
          where e.transaction_engine_v2_at is not null
          and f.reason = 'HACK CLUB FEE'
          group by cem.event_id
      ) q2

      on q1.event_id = q2.event_id
      ) q3
      where fee_balance > 0
      order by fee_balance desc
    SQL

    ActiveRecord::Base.connection.execute(query)
  end

  scope :pending_fees_v2, -> do
    where("(last_fee_processed_at is null or last_fee_processed_at <= ?) and id in (?)", 20.days.ago, self.event_ids_with_pending_fees_greater_than_0_v2.to_a.map {|a| a["event_id"] })
  end

  friendly_id :name, use: :slugged

  belongs_to :point_of_contact, class_name: 'User'

  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :users, through: :organizer_positions
  has_many :g_suites
  has_many :g_suite_accounts, through: :g_suites

  has_many :fee_relationships
  has_many :transactions, through: :fee_relationships, source: :t_transaction

  has_many :stripe_cards
  has_many :stripe_authorizations, through: :stripe_cards

  has_many :emburse_cards
  has_many :emburse_card_requests
  has_many :emburse_transfers
  has_many :emburse_transactions

  has_many :ach_transfers
  has_many :donations

  has_many :lob_addresses
  has_many :checks, through: :lob_addresses

  has_many :sponsors
  has_many :invoices, through: :sponsors

  has_many :documents

  has_many :canonical_pending_event_mappings
  has_many :canonical_pending_transactions, through: :canonical_pending_event_mappings

  has_many :canonical_event_mappings
  has_many :canonical_transactions, through: :canonical_event_mappings

  has_many :fees, through: :canonical_event_mappings

  validate :point_of_contact_is_admin

  validates :name, :sponsorship_fee, presence: true
  validates :slug, uniqueness: true, presence: true, format: { without: /\s/ }

  before_create :default_values

  # Used by the api's '/event' POST route
  def self.create_send_only(event_name, user_emails)
    ActiveRecord::Base.transaction do
      # most common POC will be the POC for this event
      point_of_contact_id = Event.all.pluck(:point_of_contact_id).max_by {|i| Event.all.count(i) }

      event = Event.create(
        name: event_name,
        start: Date.current,
        end: Date.current,
        address: 'N/A',
        sponsorship_fee: 0.07,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: false,
        point_of_contact_id: point_of_contact_id,
        is_spend_only: true,
      )

      sender = User.find_by_id point_of_contact_id

      user_emails ||= []
      user_emails.each do |email|
        OrganizerPositionInvite.create(
          sender: sender,
          event: event,
          email: email
        )
      end

      event
    end
  end

  # When a fee payment is collected from this event, what will the TX memo be?
  def fee_payment_memo
    "#{self.name} Bank Fee"
  end
  
  def admin_dropdown_description
    "#{name} - #{id}"
  end

  # displayed on /negative_events
  def self.negatives
    select { |event| event.balance < 0 || event.emburse_balance < 0 || event.fee_balance < 0 }
  end

  def emburse_department_path
    "https://app.emburse.com/budgets/#{emburse_department_id}"
  end

  def emburse_budget_limit
    # We want to count positive Emburse TXs that are either pending OR complete,
    # because pending TXs will silently switch to complete and the admin will not
    # be notified to update the Emburse budget for this event later when that happens.
    # See also PR #317.
    self.emburse_transactions.undeclined.where(emburse_card_uuid: nil).sum(:amount)
  end

  def emburse_balance
    completed_t = self.emburse_transactions.completed.sum(:amount)
    # We're including only pending charges on emburse_cards so organizers have a conservative estimate of their balance
    pending_t = self.emburse_transactions.pending.where('amount < 0').sum(:amount)
    completed_t + pending_t
  end

  def balance_v2_cents
    @balance_v2_cents ||= canonical_transactions.sum(:amount_cents)
  end

  def balance
    bank_balance = transactions.sum(:amount)
    stripe_balance = -stripe_authorizations.approved.sum(:amount)

    bank_balance + stripe_balance
  end

  # used for emburse transfers, this is the amount of money available that
  # isn't being transferred out by an emburse_transfer or isn't going to be
  # pulled out via fee -tmb@hackclub
  def balance_available
    emburse_transfer_pending = (emburse_transfers.under_review + emburse_transfers.pending).sum(&:load_amount)
    balance - emburse_transfer_pending - fee_balance
  end
  alias available_balance balance_available

  def fee_balance
    @fee_balance ||= total_fees - total_fee_payments
  end

  def fee_balance_v2_cents
    @fee_balance_v2_cents ||= total_fees_v2_cents - total_fee_payments_v2_cents
  end

  # amount of balance that fees haven't been pulled out for
  def balance_not_feed
    a_fee_balance = self.fee_balance

    self.transactions.where.not(fee_reimbursement: nil).each do |t|
      a_fee_balance -= (100 - t.fee_reimbursement.amount) if t.fee_reimbursement.amount < 100
    end

    percent = self.sponsorship_fee * 100

    (a_fee_balance * 100 / percent)
  end

  def balance_not_feed_v2_cents
    # shortcut to invert
    BigDecimal("#{fee_balance_v2_cents}") / BigDecimal("#{sponsorship_fee}")
  end

  def fee_balance_without_fee_reimbursement_reconcilliation
    a_fee_balance = self.fee_balance
    self.transactions.where.not(fee_reimbursement: nil).each do |t|
      a_fee_balance -= (100 - t.fee_reimbursement.amount) if t.fee_reimbursement.amount < 100
    end

    a_fee_balance
  end

  def plan_name
    if is_spend_only
      "spend-only"
    else
      "full fiscal sponsorship"
    end
  end

  def has_active_emburse?
    emburse_cards.active.any?
  end

  def used_emburse?
    emburse_cards.any?
  end

  def hidden?
    hidden_at.present?
  end

  def filter_data
    {
      exists: true,
      transparent: is_public?,
      omitted: omit_stats?,
      hidden: hidden?
    }
  end

  def ready_for_fee?
    last_fee_processed_at.nil? || last_fee_processed_at <= min_waiting_time_between_fees
  end

  private

  def min_waiting_time_between_fees
    20.days.ago
  end

  def default_values
    self.has_fiscal_sponsorship_document ||= true
  end

  def point_of_contact_is_admin
    return if self.point_of_contact&.admin?

    errors.add(:point_of_contact, 'must be an admin')
  end

  def total_fees
    @total_fees ||= transactions.joins(:fee_relationship).where(fee_relationships: { fee_applies: true }).sum("fee_relationships.fee_amount")
  end

  def total_fees_v2_cents
    @total_fess_v2_cents ||= fees.sum(:amount_cents_as_decimal).ceil
  end

  # fee payments are withdrawals, so negate value
  def total_fee_payments
    @total_fee_payments ||= -transactions.joins(:fee_relationship).where(fee_relationships: { is_fee_payment: true }).sum(:amount)
  end

  def total_fee_payments_v2_cents
    @total_fee_payments_v2_cents ||= -canonical_transactions.where(id: canonical_transaction_ids_from_hack_club_fees).sum(:amount_cents)
  end

  def canonical_event_mapping_ids_from_hack_club_fees
    @canonical_event_mapping_ids_from_hack_club_fees ||= fees.hack_club_fee.pluck(:canonical_event_mapping_id)
  end

  def canonical_transaction_ids_from_hack_club_fees
    @canonical_transaction_ids_from_hack_club_fees ||= CanonicalEventMapping.find(canonical_event_mapping_ids_from_hack_club_fees).pluck(:canonical_transaction_id)
  end
end
