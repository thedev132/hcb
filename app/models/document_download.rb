# frozen_string_literal: true

# == Schema Information
#
# Table name: document_downloads
#
#  id          :bigint           not null, primary key
#  ip_address  :inet
#  user_agent  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_document_downloads_on_document_id  (document_id)
#  index_document_downloads_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (user_id => users.id)
#
class DocumentDownload < ApplicationRecord
  belongs_to :document, inverse_of: :downloads
  belongs_to :user

  validates_presence_of :ip_address

  def self.from_request(request, params = {})
    DocumentDownload.new(
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      **params
    )
  end

end
