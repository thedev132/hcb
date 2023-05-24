# frozen_string_literal: true

# == Schema Information
#
# Table name: receipts
#
#  id                 :bigint           not null, primary key
#  attempted_match_at :datetime
#  receiptable_type   :string
#  upload_method      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  receiptable_id     :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_receipts_on_receiptable_type_and_receiptable_id  (receiptable_type,receiptable_id)
#  index_receipts_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Receipt < ApplicationRecord
  belongs_to :receiptable, polymorphic: true, required: false

  belongs_to :user, class_name: "User", required: false
  alias_attribute :uploader, :user
  alias_attribute :transaction, :receiptable

  has_one_attached :file

  validates :file, attached: true

  validate :has_owner

  enum upload_method: {
    transaction_page: 0,
    transaction_page_drag_and_drop: 1,
    receipts_page: 2,
    receipts_page_drag_and_drop: 3,
    attach_receipt_page: 4,
    attach_receipt_page_drag_and_drop: 5,
    email: 6,
    receipt_center: 7,
    receipt_center_drag_and_drop: 8
  }

  def url
    Rails.application.routes.url_helpers.rails_blob_url(object)
  end

  def preview(resize: [512, 512])
    if file.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize_to_limit: resize).processed, only_path: true)
    elsif file.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize_to_limit: resize).processed, only_path: true)
    end
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  private

  def has_owner
    if user.nil? && receiptable.nil?
      errors.add(:base, "must belong to a user, a transaction, or both.")
    end

  end

end
