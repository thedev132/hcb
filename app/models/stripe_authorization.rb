class StripeAuthorization < ApplicationRecord
  scope :awaiting_receipt, -> { includes(:receipts).where(approved: true, receipts: { id: nil }).not(stripe_status: :reversed) }

  belongs_to :stripe_card, class_name: 'StripeCard'
  alias_attribute :card, :stripe_card
  has_one :stripe_cardholder, through: :stripe_card, as: :cardholder
  alias_attribute :cardholder, :stripe_cardholder
  has_one :event, through: :stripe_card

  enum stripe_status: { pending: 0, closed: 1, reversed: 2 }
  enum authorization_method: { keyed_in: 0, swipe: 1, chip: 2, contactless: 3, online: 4 }

  validates_uniqueness_of :stripe_id

  validates_presence_of :stripe_id, :stripe_status, :authorization_method, :amount

  def status_text
    return 'Rejected' unless approved?
    return 'Pending' if pending?
    return 'Reversed' if reversed?
    return 'Success' if approved?

    'Pending'
  end

  def status_color
    return :error unless approved?
    return :muted if pending?
    return :warning if reversed?
    return :success if approved?

    :accent
  end

  def sync_from_stripe!
    self.stripe_id = stripe_obj[:id]
    self.stripe_status = stripe_obj[:status]
    self.authorization_method = stripe_obj[:authorization_method]
    self.approved = stripe_obj[:approved]
    self.amount = stripe_obj[:amount]

    stripe_card_id = stripe_obj[:card][:id]
    self.stripe_card = StripeCard.find_by(stripe_id: stripe_card_id)
  end

  private

  def stripe_obj
    @stripe_auth_obj ||= begin
      StripeService::Issuing::Authorization.retrieve(stripe_id)
    end

    @stripe_auth_obj
  end
end
