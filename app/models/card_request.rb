class CardRequest < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :fulfilled_by, class_name: 'User', required: false
  belongs_to :event
  belongs_to :card, required: false

  validates :full_name, :shipping_address, presence: true
  validates :full_name, length: { maximum: 21 }
  validate :single_status

  def status
    return 'rejected' if rejected_at.present?
    return 'canceled' if canceled_at.present?
    return 'accepted' if accepted_at.present?
    'under review'
  end

  def send_accept_email
    CardRequestMailer.with(recipient: creator).notify_accept.deliver_later
  end

  private

  def single_status
    status_columns = [:accepted_at, :rejected_at, :canceled_at]
    columns_with_errors = status_columns.select { |col| self[col].present? }
    if columns_with_errors.count > 1
      columns_with_errors.each do |col|
        other_columns = columns_with_errors - [col]
        errors.add(col, "can’t be present along with #{other_columns}")
      end
    end
  end
end
