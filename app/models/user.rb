# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  admin_at                    :datetime
#  api_access_token_bidx       :string
#  api_access_token_ciphertext :text
#  birthday                    :date
#  email                       :text
#  full_name                   :string
#  locked_at                   :datetime
#  phone_number                :text
#  phone_number_verified       :boolean          default(FALSE)
#  pretend_is_not_admin        :boolean          default(FALSE), not null
#  seasonal_themes_enabled     :boolean          default(TRUE), not null
#  session_duration_seconds    :integer          default(2592000), not null
#  sessions_reported           :boolean          default(FALSE), not null
#  slug                        :string
#  use_sms_auth                :boolean          default(FALSE)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  webauthn_id                 :string
#
# Indexes
#
#  index_users_on_api_access_token_bidx  (api_access_token_bidx) UNIQUE
#  index_users_on_email                  (email) UNIQUE
#  index_users_on_slug                   (slug) UNIQUE
#
class User < ApplicationRecord
  has_paper_trail skip: [:api_access_token] # api_access_token_ciphertext will still be tracked
  has_encrypted :api_access_token
  blind_index :api_access_token

  include PublicIdentifiable
  set_public_id_prefix :usr

  include Commentable
  extend FriendlyId

  include PgSearch::Model
  pg_search_scope :search_name, against: [:full_name, :email, :phone_number], using: { tsearch: { prefix: true, dictionary: "english" } }

  friendly_id :slug_candidates, use: :slugged
  scope :admin, -> { where.not(admin_at: nil) }

  has_many :login_codes
  has_many :login_tokens
  has_many :user_sessions, dependent: :destroy
  has_many :organizer_position_invites, dependent: :destroy
  has_many :organizer_positions
  has_many :organizer_position_deletion_requests, inverse_of: :submitted_by
  has_many :organizer_position_deletion_requests, inverse_of: :closed_by
  has_many :webauthn_credentials

  has_many :events, through: :organizer_positions

  has_many :ops_checkins, inverse_of: :point_of_contact
  has_many :managed_events, inverse_of: :point_of_contact

  has_many :g_suite_accounts, inverse_of: :fulfilled_by
  has_many :g_suite_accounts, inverse_of: :creator

  has_many :emburse_transfers
  has_many :emburse_card_requests
  has_many :emburse_cards
  has_many :emburse_transactions, through: :emburse_cards

  has_one :stripe_cardholder
  has_many :stripe_cards, through: :stripe_cardholder
  has_many :stripe_authorizations, through: :stripe_cards
  has_many :receipts

  has_many :checks, inverse_of: :creator

  has_one_attached :profile_picture

  has_one :partner, inverse_of: :representative

  before_create :format_number
  before_save :on_phone_number_update

  validate on: :update do
    if full_name.blank? && full_name_in_database.present?
      errors.add(:full_name, "can't be blank")
    end
  end

  validate on: :update do
    # Birthday is required if the user already had a birthday
    if birthday_in_database.present? && birthday.blank?
      errors.add(:birthday, "can't be blank")
    end
  end

  validates :email, uniqueness: true, presence: true
  validates_email_format_of :email
  validates :phone_number, phone: { allow_blank: true }

  validate :profile_picture_format

  # admin? takes into account an admin user's preference
  # to pretend to be a non-admin, normal user
  def admin?
    self.admin_at.present? && !self.pretend_is_not_admin
  end

  # admin_override_pretend? ignores an admin user's
  # preference to pretend not to be an admin.
  def admin_override_pretend?
    self.admin_at.present?
  end

  def make_admin!
    update!(admin_at: Time.now)
  end

  def remove_admin!
    update!(admin_at: nil)
  end

  def first_name
    @first_name ||= begin
      return nil unless namae.given || namae.particle

      (namae.given || namae.particle).split(" ").first
    end
  end

  def last_name
    @last_name ||= begin
      return nil unless namae.family

      namae.family.split(" ").last
    end
  end

  def initial_name
    @initial_name ||= if name.strip.split(" ").count == 1
                        name
                      else
                        "#{(first_name || last_name)[0..20]} #{(last_name || first_name)[0, 1]}"
                      end
  end

  def safe_name
    # stripe requires names to be 24 chars or less, and must include a last name
    return full_name unless full_name.length > 24

    initial_name
  end

  def name
    full_name || email_handle
  end

  def initials
    words = name.split(/[^[[:word:]]]+/)
    words.any? ? words.map(&:first).join.upcase : name
  end

  def pretty_phone_number
    Phonelib.parse(self.phone_number).national
  end

  def representative?
    self.partner.present?
  end

  def represented_partner
    self.partner
  end

  def beta_features_enabled?
    events.where(beta_features_enabled: true).any?
  end

  def admin_dropdown_description
    "#{name} (#{email})"
  end

  def birthday?
    birthday.present? && birthday.month == Date.today.month && birthday.day == Date.today.day
  end

  def seasonal_themes_disabled?
    !seasonal_themes_enabled?
  end

  def locked?
    locked_at.present?
  end

  def lock!
    update!(locked_at: Time.now)

    # Invalidate all sessions
    user_sessions.destroy_all
  end

  def unlock!
    update!(locked_at: nil)
  end

  def onboarding?
    full_name.blank?
  end

  private

  def namae
    @namae ||= Namae.parse(name).first || Namae.parse(name_simplified).first || Namae::Name.new(given: name_simplified)
  end

  def name_simplified
    name.split(/[^[[:word:]]]+/).join(" ")
  end

  def email_handle
    @email_handle ||= email.split("@").first
  end

  def slug_candidates
    slug = normalize_friendly_id self.name
    # From https://github.com/norman/friendly_id/issues/480
    sequence = User.where("slug LIKE ?", "#{slug}-%").size + 2
    [slug, "#{slug} #{sequence}"]
  end

  def profile_picture_format
    return unless profile_picture.attached?
    return if profile_picture.blob.content_type.start_with? "image/"

    profile_picture.purge_later
    errors.add(:profile_picture, "needs to be an image")
  end

  def format_number
    self.phone_number = Phonelib.parse(self.phone_number).sanitized
  end

  def on_phone_number_update
    # if we previously have a phone number and the phone number is not null
    if phone_number_changed?
      # turn all this stuff off until they reverify
      self.phone_number_verified = false
      self.use_sms_auth = false
    end
  end

end
