# frozen_string_literal: true

# == Schema Information
#
# Table name: card_grants
#
#  id              :bigint           not null, primary key
#  amount_cents    :integer
#  category_lock   :string
#  email           :string           not null
#  merchant_lock   :string
#  status          :integer          default("active"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disbursement_id :bigint
#  event_id        :bigint           not null
#  sent_by_id      :bigint           not null
#  stripe_card_id  :bigint
#  subledger_id    :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_card_grants_on_disbursement_id  (disbursement_id)
#  index_card_grants_on_event_id         (event_id)
#  index_card_grants_on_sent_by_id       (sent_by_id)
#  index_card_grants_on_stripe_card_id   (stripe_card_id)
#  index_card_grants_on_subledger_id     (subledger_id)
#  index_card_grants_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (sent_by_id => users.id)
#  fk_rails_...  (stripe_card_id => stripe_cards.id)
#  fk_rails_...  (subledger_id => subledgers.id)
#  fk_rails_...  (user_id => users.id)
#
class CardGrant < ApplicationRecord
  include Hashid::Rails

  belongs_to :event
  belongs_to :subledger, optional: true
  belongs_to :stripe_card, optional: true
  belongs_to :user, optional: true
  belongs_to :sent_by, class_name: "User"
  belongs_to :disbursement, optional: true

  enum :status, [:active, :canceled], default: :active

  before_create :create_user
  before_create :create_subledger
  after_create :transfer_money
  after_create_commit :send_email

  before_validation { self.email = email.presence&.downcase&.strip }

  delegate :balance, to: :subledger

  serialize :merchant_lock, CommaSeparatedCoder # convert comma-separated merchant list to an array
  serialize :category_lock, CommaSeparatedCoder
  alias_attribute :allowed_merchants, :merchant_lock
  alias_attribute :allowed_categories, :category_lock

  validates_presence_of :amount_cents, :email
  validates :amount_cents, numericality: { greater_than: 0, message: "can't be zero!" }

  scope :not_activated, -> { active.where(stripe_card_id: nil) }
  scope :activated, -> { active.where.not(stripe_card_id: nil) }
  scope :search_recipient, ->(q) { joins(:user).where("users.full_name ILIKE :query OR card_grants.email ILIKE :query", query: "%#{User.sanitize_sql_like(q)}%") }

  monetize :amount_cents

  def name
    "#{user.name} (#{user.email})"
  end

  def state
    if canceled?
      "muted"
    elsif stripe_card.nil?
      "info"
    elsif stripe_card.frozen?
      "info"
    else
      "success"
    end
  end

  def state_text
    if canceled?
      "Canceled"
    elsif stripe_card.nil?
      "Invitation sent"
    elsif stripe_card.frozen?
      "Frozen"
    else
      "Active"
    end
  end

  def cancel!(canceled_by)
    if balance > 0
      DisbursementService::Create.new(
        source_event_id: event_id,
        destination_event_id: event_id,
        name: "Cancel of grant to #{user.email}",
        amount: balance.amount,
        source_subledger_id: subledger_id,
        requested_by_id: canceled_by.id,
      ).run
    end

    update!(status: :canceled)

    stripe_card&.freeze!
  end

  def create_stripe_card(session)
    return if stripe_card.present?

    self.stripe_card = StripeCardService::Create.new(
      card_type: "virtual",
      event_id:,
      current_user: user,
      current_session: session,
      subledger:,
    ).run

    save!
  end

  private

  def create_user
    self.user = User.find_or_create_by!(email:)
  end

  def create_subledger
    self.subledger = event.subledgers.create!
  end

  def transfer_money
    self.disbursement = DisbursementService::Create.new(
      source_event_id: event_id,
      destination_event_id: event_id,
      name: "Grant to #{user.email}",
      amount: amount.amount,
      requested_by_id: sent_by_id,
      destination_subledger_id: subledger_id,
    ).run
    save!
  end

  def send_email
    CardGrantMailer.with(card_grant: self).card_grant_notification.deliver_later
  end

end
