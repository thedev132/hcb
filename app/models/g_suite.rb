# frozen_string_literal: true

class GSuite < ApplicationRecord
  VALID_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix.freeze

  has_paper_trail

  include PgSearch::Model
  pg_search_scope :search_domain, against: [:domain]

  include AASM
  include Commentable

  belongs_to :event
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id", optional: true
  has_many :accounts, class_name: "GSuiteAccount"

  aasm do
    state :creating, initial: true
    state :configuring
    state :verifying
    state :verified

    event :mark_creating do
      transitions to: :creating
    end

    event :mark_configuring do
      transitions to: :configuring
    end

    event :mark_verifying do
      transitions from: :configuring, to: :verifying
    end

    event :mark_verified do
      transitions from: :verifying, to: :verified
    end
  end

  scope :not_deleted, -> { where("deleted_at is null") }
  scope :needs_ops_review, -> { where("deleted_at is null and aasm_state in (?)", ["creating", "verifying"]) }

  validates :domain, presence: true, format: { with: VALID_DOMAIN }
  validates_uniqueness_of :domain, conditions: -> { where(deleted_at: nil) }

  before_validation :clean_up_verification_key

  def needs_ops_review?
    @needs_ops_review ||= deleted_at.blank? && (creating? || verifying?)
  end

  def verified_on_google?
    @verified_on_google ||= ::Partners::Google::GSuite::Domain.new(domain: domain).run.verified
  rescue => e
    Airbrake.notify(e)

    false
  end

  def verification_url
    "https://www.google.com/webmasters/verification/verification?siteUrl=http://#{domain}&priorities=vdns,vmeta,vfile,vanalytics"
  end

  def dns_check_url
    "https://nslookup.io/dns-records/#{domain}"
  end

  def deleted?
    deleted_at.present?
  end

  private

  def clean_up_verification_key
    self.verification_key = verification_key.gsub("google-site-verification=", "") if verification_key.present?
  end

end
