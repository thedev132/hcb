# frozen_string_literal: true

# == Schema Information
#
# Table name: wires
#
#  id                        :bigint           not null, primary key
#  aasm_state                :string           not null
#  account_number_bidx       :string           not null
#  account_number_ciphertext :string           not null
#  amount_cents              :integer          not null
#  approved_at               :datetime
#  bic_code_bidx             :string           not null
#  bic_code_ciphertext       :string           not null
#  currency                  :string           default("USD"), not null
#  memo                      :string           not null
#  payment_for               :string           not null
#  recipient_email           :string           not null
#  recipient_name            :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_id                  :bigint           not null
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_wires_on_event_id  (event_id)
#  index_wires_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class Wire < ApplicationRecord
  has_paper_trail

  include PgSearch::Model
  pg_search_scope :search_recipient, against: [:recipient_name, :recipient_email]

  has_encrypted :account_number, :bic_code
  blind_index :account_number, :bic_code

  include AASM

  include CountryEnumable
  enum :recipient_country, self.country_enum_list, prefix: :recipient_country

  belongs_to :event
  belongs_to :user

  has_one :canonical_pending_transaction

  monetize :amount_cents, as: "amount", with_model_currency: :currency

  include PublicActivity::Model
  tracked owner: proc{ |controller, record| controller&.current_user }, event_id: proc { |controller, record| record.event.id }, only: [:create]

  def estimated_fee_cents_usd
    20_00
  end

  after_create do
    create_canonical_pending_transaction!(
      event:,
      amount_cents: -1 * (usd_amount_cents + estimated_fee_cents_usd),
      memo: "OUTGOING WIRE",
      date: created_at
    )
  end

  aasm timestamps: true, whiny_persistence: true do
    state :pending, initial: true
    state :approved
    state :rejected
    state :deposited

    event :mark_approved do
      transitions from: :pending, to: :approved
    end

    event :mark_rejected do
      after do
        canonical_pending_transaction.decline!
        create_activity(key: "wire.rejected")
      end
      transitions from: [:pending, :approved], to: :rejected
    end

    event :mark_deposited do
      transitions from: :approved, to: :deposited
    end
  end

  validates :amount_cents, numericality: { greater_than: 0, message: "must be positive!" }

  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates_presence_of :memo, :payment_for, :recipient_name, :recipient_email

  validate on: :create do
    if (usd_amount_cents + estimated_fee_cents_usd) > event.balance_available_v2_cents
      errors.add(:base, "You don't have enough money to send this transfer! Your balance is #{(event.balance_available_v2_cents / 100).to_money.format}. At current exchange rates, this transfer would cost #{((usd_amount_cents + estimated_fee_cents_usd) / 100).to_money.format} (USD, including fees).")
    end
  end

  def state
    if pending?
      :muted
    elsif rejected?
      :error
    elsif deposited?
      :success
    else
      :info
    end
  end

  def state_text
    aasm_state.humanize
  end

  alias_attribute :name, :recipient_name

  def hcb_code
    "HCB-#{TransactionGroupingEngine::Calculate::HcbCode::WIRE_CODE}-#{id}"
  end

  def admin_dropdown_description
    "#{ApplicationController.helpers.render_money(amount_cents)} to #{recipient_email} from #{event.name}"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code:)
  end

  def usd_amount_cents
    eu_bank = EuCentralBank.new
    eu_bank.update_rates
    eu_bank.exchange(amount_cents, currency, "USD").cents
  end

  def self.information_required_for(country) # country can be null, in which case, only the general fields will be returned.
    fields = []
    fields << { type: :text_area, key: "instructions", label: "Country-specific instructions", description: "Use this space to include specific details required to send to this country." }
    return fields
  end

  def self.recipient_information_accessors
    fields = []
    Event.countries_for_select.each do |country|
      fields += self.information_required_for(country)
    end
    fields.collect{ |field| field[:key] }.uniq
  end

  store :recipient_information, accessors: self.recipient_information_accessors

end
