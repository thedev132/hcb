# frozen_string_literal: true

class PartneredSignup < ApplicationRecord
  has_paper_trail
  
  include PublicIdentifiable
  set_public_id_prefix :sup

  belongs_to :partner, required: true
  belongs_to :event,   required: false
  belongs_to :user,    required: false

  validates :redirect_url, presence: true
  validate :accepted_or_rejected

  private

  def accepted_or_rejected
    if accepted_at && rejected_at
      errors.add(:base, "Cannot be both accepted and rejected")
    end
  end
end
