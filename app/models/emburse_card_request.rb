class EmburseCardRequest < ApplicationRecord
  include Rejectable
  include Commentable

  belongs_to :creator, class_name: 'User'
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :event
  belongs_to :emburse_card, required: false

  validates :full_name, presence: true
  validates :full_name, length: { maximum: 21 }
  validate :status_accepted_canceled_or_rejected

  scope :outstanding, -> { where(accepted_at: nil) }
  scope :accepted, -> { where.not(id: outstanding) }
  scope :under_review, -> { where(rejected_at: nil, canceled_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'canceled' if canceled_at.present?
    return 'accepted' if accepted_at.present?

    'under review'
  end

  def status_badge_type
    s = status.to_sym
    return :success if s == :accepted
    return :error if s == :rejected
    return :muted if s == :canceled

    :pending
  end

  def shipping_address_full
    # NOTE: when HCB was first written, EmburseCardRequest had a single field for
    # address. We later switched to a more structured address format
    # (street_one, street_two, city, state, zip) but this method wraps both
    # for backwards compatibility.
    if shipping_address.blank?
      "#{shipping_address_street_one}\n#{
        shipping_address_street_two ? shipping_address_street_two + "\n" : ''
      }#{shipping_address_city}, #{shipping_address_state} #{shipping_address_zip}"
    else
      shipping_address
    end
  end

  def emburse_department_id
    event.emburse_department_id
  end

  def under_review?
    rejected_at.nil? && canceled_at.nil? && accepted_at.nil?
  end
end
