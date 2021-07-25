# frozen_string_literal: true

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
