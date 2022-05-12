# frozen_string_literal: true

class Receipt < ApplicationRecord
  belongs_to :receiptable, polymorphic: true

  belongs_to :user, class_name: "User", required: false
  alias_attribute :uploader, :user
  alias_attribute :transaction, :receiptable

  has_one_attached :file

  validates :file, attached: true

  enum upload_method: {
    transaction_page: 0,
    transaction_page_drag_and_drop: 1,
    receipts_page: 2,
    receipts_page_drag_and_drop: 3,
    attach_receipt_page: 4,
    attach_receipt_page_drag_and_drop: 5,
    email: 6
  }

  def url
    Rails.application.routes.url_helpers.rails_blob_url(object)
  end

  def preview(resize: "512x512")
    if file.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize: resize).processed, only_path: true)
    elsif file.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize: resize).processed, only_path: true)
    end
  rescue ActiveStorage::FileNotFoundError
    nil
  end

end
