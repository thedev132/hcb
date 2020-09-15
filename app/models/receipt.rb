class Receipt < ApplicationRecord
  belongs_to :user, class_name: 'User', required: false
  alias_attribute :uploader, :user
  belongs_to :stripe_authorization, required: false
  alias_attribute :transaction, :stripe_authorization

  has_one_attached :file

  validates :file, attached: true

  def url
    Rails.application.routes.url_helpers.rails_blob_url(object)
  end

  def preview(resize: '512x512')
    if file.previewable?
      Rails.application.routes.url_helpers.rails_representation_url(file.preview(resize: resize).processed, only_path: true)
    elsif file.variable?
      Rails.application.routes.url_helpers.rails_representation_url(file.variant(resize: resize).processed, only_path: true)
    end
  end
end
