# frozen_string_literal: true

class PartneredSignup < ApplicationRecord
  has_paper_trail

  include PublicIdentifiable
  set_public_id_prefix :sup

  belongs_to :partner, required: true
  belongs_to :event,   required: false
  belongs_to :user,    required: false

  validates :redirect_url, presence: true
  validates_presence_of [:organization_name,
                         :owner_name,
                         :owner_email,
                         :owner_phone,
                         :owner_address_line1,
                         # :owner_address_line2,
                         # ^ intentionally blank, as this is optional
                         :owner_address_city,
                         :owner_address_state,
                         :owner_address_postal_code,
                         :owner_address_country,
                         :owner_birthdate], unless: :unsubmitted?

  include AASM

  aasm timestamps: true do
    state :unsubmitted, initial: true # Partner reaches out to create a signup
    state :submitted # Owner filled out details on form
    state :applicant_signed # Owner signed contract

    state :rejected # Admin turned down contract

    state :accepted # Admin signed contract
    state :completed # Signed contract has been downloaded as PDF, org has been created, users have been invited

    # The ending state of a SUP should be either `rejected` or `completed`

    event :mark_submitted do
      transitions from: :unsubmitted, to: :submitted
    end

    event :mark_applicant_signed do
      transitions from: :submitted, to: :applicant_signed

      after do
        signed_contract = true;
      end
    end

    event :mark_rejected do
      transitions from: [:submitted, :applicant_signed], to: :rejected
    end

    event :mark_accepted do
      transitions from: :applicant_signed, to: :accepted
    end

    event :mark_completed do
      transitions from: :accepted, to: :completed
    end
  end

  scope :not_unsubmitted, -> { where.not(aasm_state: :unsubmitted) }

  def continue_url
    Rails.application.routes.url_helpers.edit_partnered_signups_url(public_id: public_id)
  end

  def state_text
    aasm.human_state
  end

  def api_status
    return 'rejected' if rejected?
    return 'approved' if completed?

    # Applicant needs to sign for the contract for the SUP to be considered
    # fully submitted from the Partner's perspective.
    return 'unsubmitted' if unsubmitted? || submitted?
    return 'submitted' if applicant_signed?

    ''
  end

end
