class Transaction < ApplicationRecord
  extend FriendlyId

  paginates_per 100

  friendly_id :slug_text, use: :slugged

  acts_as_paranoid

  default_scope { order(date: :desc, id: :desc) }
  scope :uncategorized, -> { where(is_event_related: true, fee_relationship_id: nil) }

  belongs_to :bank_account

  belongs_to :fee_relationship, inverse_of: :t_transaction, required: false
  has_one :event, through: :fee_relationship

  belongs_to :load_card_request, inverse_of: :t_transaction, required: false
  belongs_to :invoice_payout, inverse_of: :t_transaction, required: false

  belongs_to :fee_reimbursement, inverse_of: :t_transaction, required: false

  belongs_to :check, inverse_of: :t_transactions, required: false
  belongs_to :ach_transfer, inverse_of: :t_transaction, required: false

  belongs_to :donation_payout, inverse_of: :t_transaction, required: false

  has_many :comments, as: :commentable

  accepts_nested_attributes_for :fee_relationship

  validates :plaid_id, uniqueness: true
  validates :is_event_related, inclusion: { in: [true, false] }

  validates :fee_relationship,
    absence: true,
    unless: -> { self.is_event_related }

  validate :ensure_paired_correctly

  after_initialize :default_values

  def self.total_volume
    self.sum('@amount').to_i
  end

  def self.during(start_time, end_time)
    self.where(["transactions.created_at > ? and transactions.created_at < ?", start_time, end_time])
  end

  def self.volume_during(start_time, end_time)
    self.during(start_time, end_time).sum('@amount').to_i
  end

  def self.raised_during(start_time, end_time)
    raised_during = self.during(start_time, end_time)
      .includes(:fee_relationship)
      .where(
        is_event_related: true,
        fee_relationships: {
          fee_applies: true,
        },
    )

    raised_during.sum(:amount).to_i
  end

  def self.revenue_during(start_time, end_time)
    fees_during = self.during(start_time, end_time)
      .includes(:fee_relationship)
      .where(
        is_event_related: true,
        fee_relationships: {
          is_fee_payment: true,
        },
    )

    # revenue for Bank is expense for Events
    -fees_during.sum(:amount).to_i
  end

  delegate :url_helpers, to: 'Rails.application.routes'
  def link
    host = Rails.application.config.action_mailer.default_url_options[:host]
    host + url_helpers.transaction_path(self)
  end

  def default_values
    self.is_event_related = true if self.is_event_related.nil?
    set_default_display_name
  end

  def set_default_display_name
    self.display_name ||= self.name
  end

  def notify_user_invoice
    MoneyReceivedMailer.with(transaction: self).money_received.deliver_later
  end

  # Utility method for getting the fee on the transaction if there is one. Used
  # in CSV export.
  def fee
    is_event_related && fee_relationship&.fee_applies && fee_relationship&.fee_amount
  end

  def fee_payment?
    is_event_related && fee_relationship&.is_fee_payment
  end

  def fee_applies?
    is_event_related && fee_relationship&.fee_applies
  end

  def categorized?
    is_event_related && fee_relationship_id
  end

  def filter_data
    {
      exists: true,
      fee_applies: self.fee_applies?,
      fee_payment: self.fee_payment?,
      emburse: self.potential_emburse?,
      expensify: self.potential_expensify?,
    }
  end

  def ensure_paired_correctly
    # NOTE: here, we have to compare to fee_relationship&.event and not just event,
    # because fee_relationship is the attribute directly set by a request to update
    # and reflects the most up-to-date value of event, and just "event" is a getter
    # that may be cached for the model and thus incorrect.

    # if linked to an invoice, check that invoice's event is transaction's event
    if !invoice_payout.nil? && invoice_payout.invoice && invoice_payout.invoice.event != fee_relationship&.event
      # NOTE: this extra check ^^^^^^^^^^^^^^^^^^^^^^ is to not break with historical data that
      # no longer correctly conforms to correct schema. (InvoicePayout without Invoice) (TX ID 5467)
      errors.add(:base, "Paired invoice payout's event must match transaction's event")
    end

    # if LCR linked, check that LCR's event is transaction's event
    if !load_card_request.nil? && load_card_request.event != fee_relationship&.event
      errors.add(:base, "Paired load card request's event must match transaction's event")
      return 3
    end
  end

  # The following set of "potential_[ xxx ]?" methods
  # use usually-reliable heuristics to try to guess
  # whether the tx is a certain kind, usually by the tx memo.
  #
  # As noted by the "potential" prefix, these are not reliable,
  # and meant to aid human work.
  #
  # They are used in try_pair_automatically! and rendering Transaction#edit
  #
  # TODO: eventually, we want to move these concerns out to their
  # corresponding models. i.e. potential_donation_payout?
  # should probably be a part of the Donation class, not Transaction.

  def potential_invoice_payout?
    (self.name.start_with?('HACKC PAYOUT') || self.name.start_with?('HACK CLUB EVENT')) && amount > 0
  end

  def potential_donation_payout?
    (self.name.start_with?('HACKC DONATE ') || self.name.start_with?('HACK CLUB EVENT')) && amount > 0
  end

  # We used to also use 'FEE REIMBURSEMENT' as prefix
  # but is deprecated, so don't look for it anymore.
  def potential_fee_reimbursement?
    self.name.start_with?('FEE REFUND')
  end

  def potential_fee_payment?
    self.name.include?('Bank Fee')
  end

  def potential_emburse?
    self.name.include?('emburse.com')
  end

  # GitHub Grants
  def potential_github?
    self.name.include?('GitHub Grant')
  end

  def potential_expensify?
    self.name.include?('Expensify')
  end

  def potential_ach_transfer?
    # Based on observations, SVB does not guarantee this TX memo
    self.name.include?('BUSBILLPAY')
  end

  def potential_check?
    # This is a guess from observation, but may not cover 100%
    # of the cases. FRB's transaction memos are weird.
    self.name.include?('DDA#') || self.name.include?('Check')
  end

  # Tries to fully pair this transaction successfully
  # re: https://github.com/hackclub/bank/issues/364
  # returns True if paired successfully, false otherwise.
  #
  # NOTE: wrap calls to this in a SQL transaction to avoid
  # broken states.
  def try_pair_automatically!
    return unless !categorized?

    if potential_invoice_payout?
      try_pair_invoice
    elsif potential_donation_payout?
      try_pair_donation
    elsif potential_fee_reimbursement?
      try_pair_fee_reimbursement
    elsif potential_fee_payment?
      try_pair_fee_payment
    elsif potential_emburse?
      try_pair_emburse
    elsif potential_github?
      try_pair_github
    elsif potential_check?
      try_pair_check
    end
    # NOTE: we cannot curently auto-pair Expensify txs
  end

  def try_pair_invoice
    return unless potential_invoice_payout?

    # tx name can be one of two forms, from observation:
    # 1. HACKC PAYOUT [PREFIX] ST-XXXXXXXXXX The Hack Foundation
    #   -- if it's a complete TX
    # 2. HACKC PAYOUT [PREFIX]
    #   -- if it's a pending TX
    # where PREFIX appears in InvoicePayout.statement_descriptor as
    #   "PAYOUT [PREFIX]"
    #
    # We should parse out the PREFIX from the TX.name, try to find any matching
    # InvoicePayouts, and match it.

    # case 1
    match = /HACKC PAYOUT (.*) ST-.*/.match(self.name)
    prefix = match ? match[1] : false
    if !prefix
      # case 2
      match = /HACKC PAYOUT (.*)/.match(self.name)
      prefix = match ? match[1] : false
    end

    # if we can't find a prefix, bail
    return unless prefix

    # find all payouts that match both amount and statement_descriptor
    payouts_matching_amount = InvoicePayout.lacking_transaction.where(amount: self.amount)
    payouts_matching_prefix = payouts_matching_amount.select { |po|
      po.statement_descriptor.start_with?('PAYOUT ' + prefix)
    }

    # if there's exactly one match, pick that one
    return unless payouts_matching_prefix.count == 1
    payout = payouts_matching_prefix[0]

    # pair the transaction
    self.invoice_payout = payout
    self.fee_relationship = FeeRelationship.new(
      event_id: payout.invoice.event.id,
      fee_applies: true
    )

    self.display_name = "Invoice to #{payout.invoice.sponsor.name}"
    self.save
  end

  def try_pair_donation
    return unless potential_donation_payout?

    # tx name can be one of two forms, from observation:
    # 1. HACKC DONATE [PREFIX] ST-XXXXXXXXXX The Hack Foundation
    #   -- if it's a complete TX
    # 2. HACKC DONATE [PREFIX]
    #   -- if it's a pending TX
    # where PREFIX appears in DonationPayout.statement_descriptor as
    #   "DONATE [PREFIX]"
    #
    # We should parse out the PREFIX from the TX.name, try to find any matching
    # DonationPayouts, and match it.

    # case 1
    match = /HACKC DONATE (.*) ST-.*/.match(self.name)
    prefix = match ? match[1] : false
    if !prefix
      # case 2
      match = /HACKC DONATE (.*)/.match(self.name)
      prefix = match ? match[1] : false
    end

    # if we can't find a prefix, bail
    return unless prefix

    # find all payouts that match both amount and statement_descriptor
    payouts_matching_amount = DonationPayout.lacking_transaction.where(amount: self.amount)
    payouts_matching_prefix = payouts_matching_amount.select { |po|
      po.statement_descriptor.start_with?('DONATE ' + prefix)
    }

    # if there's exactly one match, pick that one
    return unless payouts_matching_prefix.count == 1
    payout = payouts_matching_prefix[0]

    # pair the transaction
    self.donation_payout = payout
    self.fee_relationship = FeeRelationship.new(
      event_id: payout.donation.event.id,
      fee_applies: true
    )

    self.display_name = "Donation from #{payout.donation.name}"
    self.save
  end

  def try_pair_fee_reimbursement
    return unless potential_fee_reimbursement?

    FeeReimbursement.pending.each do |reimbursement|
      if (self.name.start_with? reimbursement.transaction_memo)
        return unless reimbursement.payout&.t_transaction
        return unless self.amount == reimbursement.amount || reimbursement.amount < 100 && self.amount == 100

        reimbursement.t_transaction = self

        self.fee_relationship = FeeRelationship.new(
          event_id: reimbursement.event.id,
          fee_applies: true,
          fee_amount: reimbursement.calculate_fee_amount
        )

        self.display_name = reimbursement.transaction_display_name
        self.save

        break
      end
    end
  end

  def try_pair_fee_payment
    return unless potential_fee_payment?

    # TODO: event names might use special chars in their names
    # that are not valid SVB TX memos. In that case, we may have to
    # switch to selecting events whose fee_payment_memo() matches instead
    # of this regex matching thing.
    potential_event_name = /(.*) Bank Fee.*/.match(self.name)[1]
    matching_events = Event.where(name: potential_event_name)

    return unless matching_events.count == 1
    event = matching_events[0]

    self.fee_relationship = FeeRelationship.new(
      event_id: event.id,
      is_fee_payment: true,
    )

    self.save
  end

  def try_pair_emburse
    return unless potential_emburse?

    # load card requests will be negative on the account balance
    unpaired_matching_amount = LoadCardRequest
      .unpaired.where(load_amount: -self.amount)
      .order(accepted_at: :desc)

    return unless unpaired_matching_amount.count > 0
    lcr = unpaired_matching_amount[0]

    self.load_card_request = lcr

    self.fee_relationship = FeeRelationship.new(
      event_id: lcr.event.id,
      fee_applies: false
    )

    self.display_name = "Transfer from account to card balance"
    self.save
  end

  def try_pair_github
    return unless potential_github?

    potential_event_name = /(.*) GitHub Grant.*/.match(self.name)[1]
    matching_events = Event.where(name: potential_event_name)

    return unless matching_events.count == 1
    event = matching_events[0]

    self.fee_relationship = FeeRelationship.new(
      event_id: event.id,
      fee_applies: false
    )

    self.save
  end

  def try_pair_check
    return unless potential_check?

    Check.approved.each do |check|
      if check.in_transit? && self.amount.abs == check.amount.abs
        self.check = check

        self.fee_relationship = FeeRelationship.new(
          event_id: check.event.id,
          fee_applies: false
        )

        self.display_name = "Check to #{check.lob_address.name}"
        self.save

        break
      end
    end
  end

  private

  def slug_text
    "#{date} #{name}"
  end

  def filter_for(text)
    name&.downcase&.include? text
  end

end
