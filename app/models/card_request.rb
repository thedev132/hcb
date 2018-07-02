class CardRequest < ApplicationRecord
  include Rejectable

  belongs_to :creator, class_name: 'User'
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :event
  belongs_to :card, required: false

  validates :full_name, :shipping_address, presence: true
  validates :full_name, length: { maximum: 21 }
  validate :status_accepted_canceled_or_rejected

  scope :outstanding, -> { where(accepted_at: nil) }
  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'canceled' if canceled_at.present?
    return 'accepted' if accepted_at.present?
    'under review'
  end

  def under_review?
    rejected_at.nil? && canceled_at.nil? && accepted_at.nil?
  end

  def send_accept_email
    CardRequestMailer.with(card_request: self).accepted.deliver_later
  end
end
