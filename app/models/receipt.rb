# frozen_string_literal: true

# == Schema Information
#
# Table name: receipts
#
#  id                         :bigint           not null, primary key
#  receiptable_type           :string
#  textual_content_ciphertext :text
#  upload_method              :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  receiptable_id             :bigint
#  user_id                    :bigint
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
  has_encrypted :textual_content

  include PublicIdentifiable
  set_public_id_prefix :rct

  belongs_to :receiptable, polymorphic: true, required: false

  belongs_to :user, class_name: "User", required: false
  alias_attribute :uploader, :user
  alias_method :transaction, :receiptable

  has_many :suggested_pairings, dependent: :destroy
  has_many :suggested_transactions, source: :hcb_code, through: :suggested_pairings

  has_one_attached :file

  validates :file, attached: true

  before_create do
    suppress(ActiveModel::MissingAttributeError) do
      receiptable&.update(marked_no_or_lost_receipt_at: nil)
    end
  end

  after_create_commit do
    # Queue async job to extract text from newly upload receipt
    ReceiptJob::ExtractTextualContent.perform_later(self)
  end
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
    receipt_center_drag_and_drop: 8,
    api: 9,
  }

  def url
    Rails.application.routes.url_helpers.rails_blob_url(file)
  end

  def preview(resize: "512x512", only_path: true)
    if file.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize:).processed, only_path:)
    elsif file.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize:).processed, only_path:)
    end
  rescue
    nil
  end

  def extract_textual_content
    text = case file.content_type
           when "application/pdf"
             pdf_text
           else
             # Unable to extract text from this file type
             return nil
           end

    # Clean the text
    text ||= ""
    text.strip
  rescue => e
    # "ArgumentError: string contains null byte" is a known error
    unless e.is_a?(ArgumentError) && e.message.include?("string contains null byte")
      Airbrake.notify(e, receipt_id: id)
    end

    # Since text extraction can be a resource intensive operation, saving an
    # empty string indicates that no text was able to be extracted. This
    # prevents the text extraction from being unintentionally attempted again.
    ""
  end

  def extract_textual_content!
    extract_textual_content.tap do |text|
      update!(textual_content: text)
    end
  end

  def has_textual_content?
    !!(textual_content || extract_textual_content!)
  end

  private

  def pdf_text
    doc = Poppler::Document.new(file.download)
    doc.pages.map(&:text).join(" ")
  end

  def has_owner
    if user.nil? && receiptable.nil?
      errors.add(:base, "must belong to a user, a transaction, or both.")
    end

  end

end
