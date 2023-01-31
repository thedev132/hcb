# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                              :bigint           not null, primary key
#  aasm_state                      :string
#  address                         :text
#  beta_features_enabled           :boolean
#  can_front_balance               :boolean          default(FALSE), not null
#  category                        :integer
#  country                         :integer
#  custom_css_url                  :string
#  demo_mode                       :boolean          default(FALSE), not null
#  demo_mode_request_meeting_at    :datetime
#  donation_page_enabled           :boolean          default(TRUE)
#  donation_page_message           :text
#  end                             :datetime
#  expected_budget                 :integer
#  has_fiscal_sponsorship_document :boolean
#  hidden_at                       :datetime
#  holiday_features                :boolean          default(TRUE), not null
#  is_indexable                    :boolean          default(TRUE)
#  is_public                       :boolean          default(TRUE)
#  last_fee_processed_at           :datetime
#  name                            :text
#  omit_stats                      :boolean          default(FALSE)
#  organization_identifier         :string           not null
#  organized_by_hack_clubbers      :boolean
#  owner_address                   :string
#  owner_birthdate                 :date
#  owner_email                     :string
#  owner_name                      :string
#  owner_phone                     :string
#  pending_transaction_engine_at   :datetime         default(Sat, 13 Feb 2021 22:49:40.981965000 UTC +00:00)
#  public_message                  :text
#  redirect_url                    :string
#  slug                            :text
#  sponsorship_fee                 :decimal(, )
#  start                           :datetime
#  transaction_engine_v2_at        :datetime
#  webhook_url                     :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  club_airtable_id                :text
#  emburse_department_id           :string
#  partner_id                      :bigint           not null
#  point_of_contact_id             :bigint
#
# Indexes
#
#  index_events_on_club_airtable_id                        (club_airtable_id) UNIQUE
#  index_events_on_partner_id                              (partner_id)
#  index_events_on_partner_id_and_organization_identifier  (partner_id,organization_identifier) UNIQUE
#  index_events_on_point_of_contact_id                     (point_of_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (partner_id => partners.id)
#  fk_rails_...  (point_of_contact_id => users.id)
#
class Event < ApplicationRecord
  include Hashid::Rails
  extend FriendlyId

  include PublicIdentifiable
  set_public_id_prefix :org

  include CountryEnumable
  has_country_enum :country

  has_paper_trail

  include AASM
  include PgSearch::Model
  pg_search_scope :search_name, against: [:name, :slug, :id], using: { tsearch: { prefix: true, dictionary: "simple" } }

  monetize :total_fees_v2_cents

  default_scope { order(id: :asc) }
  scope :pending, -> { where(aasm_state: :pending) }
  scope :pending_or_unapproved, -> { where(aasm_state: [:pending, :unapproved]) }
  scope :transparent, -> { where(is_public: true) }
  scope :not_transparent, -> { where(is_public: false) }
  scope :indexable, -> { where(is_public: true, is_indexable: true, demo_mode: false) }
  scope :omitted, -> { where(omit_stats: true) }
  scope :not_omitted, -> { where(omit_stats: false) }
  scope :hidden, -> { where("hidden_at is not null") }
  scope :v1, -> { where(transaction_engine_v2_at: nil) }
  scope :v2, -> { where.not(transaction_engine_v2_at: nil) }
  scope :not_partner, -> { where(partner_id: 1) }
  scope :partner, -> { where.not(partner_id: 1) }
  scope :hidden, -> { where.not(hidden_at: nil) }
  scope :not_hidden, -> { where(hidden_at: nil) }
  scope :funded, -> {
    includes(canonical_event_mappings: :canonical_transaction)
      .where("canonical_transactions.amount_cents > 0")
      .references(:canonical_transaction)
  }
  scope :not_funded, -> { where.not(id: funded) }
  scope :organized_by_hack_clubbers, -> { where(organized_by_hack_clubbers: true) }
  scope :not_organized_by_hack_clubbers, -> { where.not(organized_by_hack_clubbers: true) }
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
    where("(last_fee_processed_at is null or last_fee_processed_at <= ?) and id in (?)", 5.days.ago, self.event_ids_with_pending_fees_greater_than_100.to_a.map { |a| a["event_id"] })
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
    where("(last_fee_processed_at is null or last_fee_processed_at <= ?) and id in (?)", 5.days.ago, self.event_ids_with_pending_fees_greater_than_0_v2.to_a.map { |a| a["event_id"] })
  end

  scope :demo_mode, -> { where(demo_mode: true) }
  scope :not_demo_mode, -> { where(demo_mode: false) }
  scope :filter_demo_mode, ->(demo_mode) { demo_mode.nil? || demo_mode.blank? ? all : where(demo_mode: demo_mode) }

  BADGES = {
    # Qualifier must be a method on Event. If the method returns true, the badge
    # will be displayed for the event.
    omit_stats: {
      qualifier: :omit_stats?,
      emoji: '🏦',
      description: 'Omitted from stats'
    },
    transparent: {
      qualifier: :is_public?,
      emoji: '📈',
      description: 'Transparency mode enabled'
    },
    hidden: {
      qualifier: :hidden_at?,
      emoji: '🕵️‍♂️',
      description: 'Hidden'
    },
    organized_by_hack_clubbers: {
      qualifier: :organized_by_hack_clubbers?,
      emoji: '🦕',
      description: 'Organized by Hack Clubbers'
    },
    demo_mode: {
      qualifier: :demo_mode?,
      emoji: '🧪',
      description: 'Demo Account'
    },
    winter_hardware_grant: {
      qualifier: :hardware_grant?,
      emoji: '❄️',
      description: 'Winter hardware grant'
    }
  }.freeze

  aasm do
    # All events should be approved prior to creation
    state :approved, initial: true # Full fiscal sponsorship
    state :rejected # Rejected from fiscal sponsorship

    # DEPRECATED
    state :awaiting_connect # Initial state of partner events. Waiting for user to fill out Bank Connect form
    state :pending # Awaiting Bank approval (after filling out Bank Connect form)
    state :unapproved # Old spend only events. Deprecated, should not be granted to any new events

    event :mark_pending do
      transitions from: [:awaiting_connect, :approved], to: :pending
    end

    event :mark_approved do
      transitions from: [:awaiting_connect, :pending, :unapproved], to: :approved
    end

    event :mark_rejected do
      transitions to: :rejected # from any state
    end
  end

  friendly_id :name, use: :slugged

  belongs_to :point_of_contact, class_name: "User", optional: true

  # Used for tracking slug history
  has_many :slugs, -> { order(id: :desc) }, class_name: "FriendlyId::Slug", as: :sluggable

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
  has_many :disbursements
  has_many :incoming_disbursements, class_name: "Disbursement", foreign_key: :event_id
  has_many :outgoing_disbursements, class_name: "Disbursement", foreign_key: :source_event_id
  has_many :donations
  has_many :donation_payouts, through: :donations, source: :payout

  has_many :lob_addresses
  has_many :checks, through: :lob_addresses

  has_many :sponsors
  has_many :invoices, through: :sponsors
  has_many :payouts, through: :invoices

  has_many :documents

  has_many :canonical_pending_event_mappings
  has_many :canonical_pending_transactions, through: :canonical_pending_event_mappings

  has_many :canonical_event_mappings
  has_many :canonical_transactions, through: :canonical_event_mappings

  has_many :fees, through: :canonical_event_mappings
  has_many :bank_fees

  has_many :tags, -> { includes(:hcb_codes) }

  belongs_to :partner
  has_one :partnered_signup, required: false
  has_many :partner_donations

  has_one_attached :donation_header_image
  has_one_attached :logo

  validate :point_of_contact_is_admin

  include ::UserService::CanOpenDemoMode
  attr_accessor :demo_mode_limit_email

  validate :demo_mode_limit, if: proc{ |e| e.demo_mode_limit_email }

  validates :name, :sponsorship_fee, :organization_identifier, presence: true
  validates :slug, uniqueness: true, presence: true, format: { without: /\s/ }

  after_save :update_slug_history

  CUSTOM_SORT = Arel.sql(
    "CASE WHEN id = 183 THEN '1'"\
    "WHEN id = 999 THEN '2'     "\
    "WHEN id = 689 THEN '3'     "\
    "WHEN id = 636 THEN '4'     "\
    "WHEN id = 506 THEN '5'     "\
    "ELSE 'z' || name END ASC   "
  )

  enum category: {
    hackathon: 0,
    'hack club': 1,
    nonprofit: 2,
    event: 3,
    'high school hackathon': 4,
    'robotics team': 5,
    'hardware grant': 6,
    'hack club hq': 7
  }

  def country_us?
    country == "US"
  end

  def admin_formatted_name
    "#{name} (#{id})"
  end

  # When a fee payment is collected from this event, what will the TX memo be?
  def fee_payment_memo
    "#{self.name} Bank Fee"
  end

  def admin_dropdown_description
    desc = "#{name} - #{id}"

    badges = BADGES.map { |_, badge| send(badge[:qualifier]) ? badge[:emoji] : nil }.compact
    desc += " [#{badges.join(' ')}]" if badges.any?

    desc
  end

  def disbursement_dropdown_description
    "#{name} (#{ApplicationController.helpers.render_money balance})"
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
    pending_t = self.emburse_transactions.pending.where("amount < 0").sum(:amount)
    completed_t + pending_t
  end

  def balance_v2_cents(start_date: nil, end_date: nil)
    @balance_v2_cents ||=
      begin
        sum = settled_balance_cents(start_date: start_date, end_date: end_date)
        sum += pending_outgoing_balance_v2_cents(start_date: start_date, end_date: end_date)
        sum += fronted_incoming_balance_v2_cents(start_date: start_date, end_date: end_date) if can_front_balance?
        sum
      end
  end

  # This calculates v2 cents of settled (Canonical Transactions)
  # @return [Integer] Balance in cents (v2 transaction engine)
  def settled_balance_cents(start_date: nil, end_date: nil)
    @balance_settled ||=
      settled_incoming_balance_cents(start_date: start_date, end_date: end_date) +
      settled_outgoing_balance_cents(start_date: start_date, end_date: end_date)
  end

  # v2 cents (v2 transaction engine)
  def settled_incoming_balance_cents(start_date: nil, end_date: nil)
    @settled_incoming_balance_cents ||=
      begin
        ct = canonical_transactions.where("amount_cents > 0")

        ct = ct.where("date >= ?", start_date) if start_date
        ct = ct.where("date <= ?", end_date) if end_date

        ct.sum(:amount_cents)
      end
  end

  # v2 cents (v2 transaction engine)
  def settled_outgoing_balance_cents(start_date: nil, end_date: nil)
    @settled_outgoing_balance_cents ||=
      begin
        ct = canonical_transactions.where("amount_cents < 0")

        ct = ct.where("date >= ?", start_date) if start_date
        ct = ct.where("date <= ?", end_date) if end_date

        ct.sum(:amount_cents)
      end
  end

  def fronted_incoming_balance_v2_cents(start_date: nil, end_date: nil)
    @fronted_incoming_balance_v2_cents ||=
      begin
        pts = canonical_pending_transactions.incoming.fronted.not_declined

        pts = pts.where("date >= ?", @start_date) if @start_date
        pts = pts.where("date <= ?", @end_date) if @end_date

        pt_sum_by_hcb_code = pts.group(:hcb_code).sum(:amount_cents)
        hcb_codes = pt_sum_by_hcb_code.keys

        ct_sum_by_hcb_code = canonical_transactions.where(hcb_code: hcb_codes)
                                                   .group(:hcb_code)
                                                   .sum(:amount_cents)

        pt_sum_by_hcb_code.reduce 0 do |sum, (hcb_code, pt_sum)|
          sum + [pt_sum - (ct_sum_by_hcb_code[hcb_code] || 0), 0].max
        end
      end
  end

  def pending_balance_v2_cents(start_date: nil, end_date: nil)
    @pending_balance_v2_cents ||=
      pending_incoming_balance_v2_cents(start_date: start_date, end_date: end_date) +
      pending_outgoing_balance_v2_cents(start_date: start_date, end_date: end_date)
  end

  def pending_incoming_balance_v2_cents(start_date: nil, end_date: nil)
    @pending_incoming_balance_v2_cents ||=
      begin
        cpt = canonical_pending_transactions.incoming.unsettled.not_fronted

        cpt = cpt.where("date >= ?", start_date) if start_date
        cpt = cpt.where("date <= ?", end_date) if end_date

        cpt.sum(:amount_cents)
      end
  end

  def pending_outgoing_balance_v2_cents(start_date: nil, end_date: nil)
    @pending_outgoing_balance_v2_cents ||=
      begin
        cpt = canonical_pending_transactions.outgoing.unsettled

        cpt = cpt.where("date >= ?", start_date) if start_date
        cpt = cpt.where("date <= ?", end_date) if end_date

        cpt.sum(:amount_cents)
      end
  end

  def balance_available_v2_cents
    @balance_available_v2_cents ||= balance_v2_cents - (can_front_balance? ? fronted_fee_balance_v2_cents : fee_balance_v2_cents)
  end

  def balance
    return balance_v2_cents if transaction_engine_v2_at.present?

    bank_balance = transactions.sum(:amount)
    stripe_balance = -stripe_authorizations.approved.sum(:amount)

    bank_balance + stripe_balance
  end

  # used for emburse transfers, this is the amount of money available that
  # isn't being transferred out by an emburse_transfer or isn't going to be
  # pulled out via fee -tmb@hackclub
  def balance_available
    return balance_available_v2_cents if transaction_engine_v2_at.present?

    emburse_transfer_pending = (emburse_transfers.under_review + emburse_transfers.pending).sum(&:load_amount)
    balance - emburse_transfer_pending - fee_balance
  end

  alias available_balance balance_available

  def fee_balance
    return fee_balance_v2_cents if transaction_engine_v2_at.present?

    @fee_balance ||= total_fees - total_fee_payments
  end

  # `fee_balance_v2_cents`, but it includes fees on fronted (unsettled) transactions to prevent overspending before fees are charged
  def fronted_fee_balance_v2_cents
    feed_fronted_balance = canonical_pending_transactions
                           .incoming
                           .fronted
                           .not_declined
                           .where(raw_pending_incoming_disbursement_transaction_id: nil) # We don't charge fees on disbursements
                           .sum(&:fronted_amount)

    # TODO: make sure this has the same rounding error has the rest of the codebase
    fee_balance_v2_cents + (feed_fronted_balance * sponsorship_fee)
  end

  # This intentionally does not include fees on fronted transactions to make sure they aren't actually charged
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
    # shortcut to invert - TODO: DEPRECATE. dangerous - causes incorrect calculations
    BigDecimal(fee_balance_v2_cents.to_s) / BigDecimal(sponsorship_fee.to_s)
  end

  def fee_balance_without_fee_reimbursement_reconcilliation
    a_fee_balance = self.fee_balance
    self.transactions.where.not(fee_reimbursement: nil).each do |t|
      a_fee_balance -= (100 - t.fee_reimbursement.amount) if t.fee_reimbursement.amount < 100
    end

    a_fee_balance
  end

  def plan_name
    if unapproved?
      "pending approval"
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

  def total_fees_v2_cents
    @total_fess_v2_cents ||= fees.sum(:amount_cents_as_decimal).ceil
  end

  private

  def min_waiting_time_between_fees
    5.days.ago
  end

  def point_of_contact_is_admin
    return unless point_of_contact # for remote partner created events
    return if point_of_contact&.admin_override_pretend?

    errors.add(:point_of_contact, "must be an admin")
  end

  def total_fees
    @total_fees ||= transactions.joins(:fee_relationship).where(fee_relationships: { fee_applies: true }).sum("fee_relationships.fee_amount")
  end

  # fee payments are withdrawals, so negate value
  def total_fee_payments
    @total_fee_payments ||= -transactions.joins(:fee_relationship).where(fee_relationships: { is_fee_payment: true }).sum(:amount)
  end

  def total_fee_payments_v2_cents
    @total_fee_payments_v2_cents ||=
      canonical_transactions.where(id: canonical_transaction_ids_from_hack_club_fees).sum(:amount_cents).abs +
      canonical_pending_transactions.bank_fee.unsettled.sum(:amount_cents).abs
  end

  def canonical_event_mapping_ids_from_hack_club_fees
    @canonical_event_mapping_ids_from_hack_club_fees ||= fees.hack_club_fee.pluck(:canonical_event_mapping_id)
  end

  def canonical_transaction_ids_from_hack_club_fees
    @canonical_transaction_ids_from_hack_club_fees ||= CanonicalEventMapping.find(canonical_event_mapping_ids_from_hack_club_fees).pluck(:canonical_transaction_id)
  end

  def update_slug_history
    if slug_previously_changed?
      slugs.create(slug: slug)
    end
  end

  def demo_mode_limit
    return if can_open_demo_mode? demo_mode_limit_email

    errors.add(:demo_mode, "limit reached for user")
  end

end
