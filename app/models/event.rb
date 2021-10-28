# frozen_string_literal: true

class Event < ApplicationRecord
  include Hashid::Rails
  extend FriendlyId

  include PublicIdentifiable
  set_public_id_prefix :org

  include AASM
  include PgSearch::Model
  pg_search_scope :search_name, against: [:name, :slug], using: { tsearch: { prefix: true, dictionary: "english" } }

  monetize :total_fees_v2_cents

  default_scope { order(id: :asc) }
  scope :pending, -> { where(aasm_state: :pending) }
  scope :pending_or_unapproved, -> { where(aasm_state: [:pending, :unapproved]) }
  scope :transparent, -> { where(is_public: true) }
  scope :not_transparent, -> { where(is_public: false) }
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

  aasm do
    state :awaiting_connect, initial: true # Initial state of partner events. Waiting for user to fill out Bank Connect form
    state :pending # Awaiting Bank approval (after filling out Bank Connect form)
    state :approved # Full fiscal sponsorship
    state :rejected # Rejected from fiscal sponsorship

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
  belongs_to :partner

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

  has_many :partner_donations

  enum country: {
    AF: 1,
    AX: 2,
    AL: 3,
    DZ: 4,
    AS: 5,
    AD: 6,
    AO: 7,
    AI: 8,
    AQ: 9,
    AG: 10,
    AR: 11,
    AM: 12,
    AW: 13,
    AU: 14,
    AT: 15,
    AZ: 16,
    BS: 17,
    BH: 18,
    BD: 19,
    BB: 20,
    BY: 21,
    BE: 22,
    BZ: 23,
    BJ: 24,
    BM: 25,
    BT: 26,
    BO: 27,
    BQ: 28,
    BA: 29,
    BW: 30,
    BV: 31,
    BR: 32,
    IO: 33,
    BN: 34,
    BG: 35,
    BF: 36,
    BI: 37,
    CV: 38,
    KH: 39,
    CM: 40,
    CA: 41,
    KY: 42,
    CF: 43,
    TD: 44,
    CL: 45,
    CN: 46,
    CX: 47,
    CC: 48,
    CO: 49,
    KM: 50,
    CG: 51,
    CD: 52,
    CK: 53,
    CR: 54,
    CI: 55,
    HR: 56,
    CU: 57,
    CW: 58,
    CY: 59,
    CZ: 60,
    DK: 61,
    DJ: 62,
    DM: 63,
    DO: 64,
    EC: 65,
    EG: 66,
    SV: 67,
    GQ: 68,
    ER: 69,
    EE: 70,
    SZ: 71,
    ET: 72,
    FK: 73,
    FO: 74,
    FJ: 75,
    FI: 76,
    FR: 77,
    GF: 78,
    PF: 79,
    TF: 80,
    GA: 81,
    GM: 82,
    GE: 83,
    DE: 84,
    GH: 85,
    GI: 86,
    GR: 87,
    GL: 88,
    GD: 89,
    GP: 90,
    GU: 91,
    GT: 92,
    GG: 93,
    GN: 94,
    GW: 95,
    GY: 96,
    HT: 97,
    HM: 98,
    VA: 99,
    HN: 100,
    HK: 101,
    HU: 102,
    IS: 103,
    IN: 104,
    ID: 105,
    IR: 106,
    IQ: 107,
    IE: 108,
    IM: 109,
    IL: 110,
    IT: 111,
    JM: 112,
    JP: 113,
    JE: 114,
    JO: 115,
    KZ: 116,
    KE: 117,
    KI: 118,
    KP: 119,
    KR: 120,
    KW: 121,
    KG: 122,
    LA: 123,
    LV: 124,
    LB: 125,
    LS: 126,
    LR: 127,
    LY: 128,
    LI: 129,
    LT: 130,
    LU: 131,
    MO: 132,
    MG: 133,
    MW: 134,
    MY: 135,
    MV: 136,
    ML: 137,
    MT: 138,
    MH: 139,
    MQ: 140,
    MR: 141,
    MU: 142,
    YT: 143,
    MX: 144,
    FM: 145,
    MD: 146,
    MC: 147,
    MN: 148,
    ME: 149,
    MS: 150,
    MA: 151,
    MZ: 152,
    MM: 153,
    NA: 154,
    NR: 155,
    NP: 156,
    NL: 157,
    NC: 158,
    NZ: 159,
    NI: 160,
    NE: 161,
    NG: 162,
    NU: 163,
    NF: 164,
    MK: 165,
    MP: 166,
    NO: 167,
    OM: 168,
    PK: 169,
    PW: 170,
    PS: 171,
    PA: 172,
    PG: 173,
    PY: 174,
    PE: 175,
    PH: 176,
    PN: 177,
    PL: 178,
    PT: 179,
    PR: 180,
    QA: 181,
    RE: 182,
    RO: 183,
    RU: 184,
    RW: 185,
    BL: 186,
    SH: 187,
    KN: 188,
    LC: 189,
    MF: 190,
    PM: 191,
    VC: 192,
    WS: 193,
    SM: 194,
    ST: 195,
    SA: 196,
    SN: 197,
    RS: 198,
    SC: 199,
    SL: 200,
    SG: 201,
    SX: 202,
    SK: 203,
    SI: 204,
    SB: 205,
    SO: 206,
    ZA: 207,
    GS: 208,
    SS: 209,
    ES: 210,
    LK: 211,
    SD: 212,
    SR: 213,
    SJ: 214,
    US: 215,
    SE: 216,
    CH: 217,
    SY: 218,
    TW: 219,
    TJ: 220,
    TZ: 221,
    TH: 222,
    TL: 223,
    TG: 224,
    TK: 225,
    TO: 226,
    TT: 227,
    TN: 228,
    TR: 229,
    TM: 230,
    TC: 231,
    TV: 232,
    UG: 233,
    UA: 234,
    AE: 235,
    GB: 236,
    UM: 237,
    UY: 238,
    UZ: 239,
    VU: 240,
    VE: 241,
    VN: 242,
    VG: 243,
    VI: 244,
    WF: 245,
    EH: 246,
    YE: 247,
    ZW: 249,
    ZM: 248,
  }

  validate :point_of_contact_is_admin

  validates :name, :sponsorship_fee, :organization_identifier, presence: true
  validates :slug, uniqueness: true, presence: true, format: { without: /\s/ }

  CUSTOM_SORT = "CASE WHEN id = 183 THEN '1'
                      WHEN id = 999 THEN '2'
                      WHEN id = 689 THEN '3'
                      WHEN id = 636 THEN '4'
                      ELSE 'z' || name END ASC"

  def admin_formatted_name
    "#{name} (#{id})"
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
    pending_t = self.emburse_transactions.pending.where("amount < 0").sum(:amount)
    completed_t + pending_t
  end

  def balance_v2_cents
    @balance_v2_cents ||= canonical_transactions.sum(:amount_cents) + pending_outgoing_balance_v2_cents
  end

  def pending_balance_v2_cents
    @pending_balance_v2_cents ||= pending_incoming_balance_v2_cents + pending_outgoing_balance_v2_cents
  end

  def pending_incoming_balance_v2_cents
    @pending_incoming_balance_v2_cents ||= canonical_pending_transactions.incoming.unsettled.sum(:amount_cents)
  end

  def pending_outgoing_balance_v2_cents
    @pending_outgoing_balance_v2_cents ||= canonical_pending_transactions.outgoing.unsettled.sum(:amount_cents)
  end

  def balance_available_v2_cents
    @balance_available_v2_cents ||= balance_v2_cents - fee_balance_v2_cents
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
    return if point_of_contact&.admin?

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
    @total_fee_payments_v2_cents ||= -canonical_transactions.where(id: canonical_transaction_ids_from_hack_club_fees).sum(:amount_cents)
  end

  def canonical_event_mapping_ids_from_hack_club_fees
    @canonical_event_mapping_ids_from_hack_club_fees ||= fees.hack_club_fee.pluck(:canonical_event_mapping_id)
  end

  def canonical_transaction_ids_from_hack_club_fees
    @canonical_transaction_ids_from_hack_club_fees ||= CanonicalEventMapping.find(canonical_event_mapping_ids_from_hack_club_fees).pluck(:canonical_transaction_id)
  end
end
