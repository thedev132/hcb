class User < ApplicationRecord
  include Commentable
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged
  scope :admin, -> { where.not(admin_at: nil) }

  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :organizer_position_deletion_requests, inverse_of: :submitted_by
  has_many :organizer_position_deletion_requests, inverse_of: :closed_by

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

  before_create :create_session_token
  before_create :format_number

  validates_presence_of :api_id, :api_access_token, :email
  validates_uniqueness_of :api_id, :api_access_token, :email
  validates :phone_number, phone: { allow_blank: true }
  validate :profile_picture_format

  def self.new_session_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

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

  def api_record
    ::Partners::HackclubApi::GetUser.new(user_id: api_id, access_token: api_access_token).run
  end

  def first_name
    @first_name ||= begin
      return nil unless namae.given || namae.particle

      (namae.given || namae.particle).split(' ').first
    end
  end

  def last_name
    @last_name ||= begin
      return nil unless namae.family

      namae.family.split(' ').last
    end
  end

  def initial_name
    @initial_name ||= "#{(first_name || last_name)[0..17]} #{(last_name || first_name)[0,1]}"
  end

  def safe_name
    # emburse requires names to be 21 chars or less, and must include a last name
    return full_name unless full_name.length > 21

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

  private

  def namae
    @namae ||= Namae.parse(name).first || Namae.parse(name_simplified).first || Namae::Name.new(given: name_simplified)
  end

  def name_simplified
    name.split(/[^[[:word:]]]+/).join(' ')
  end

  def email_handle
    @email_handle ||= email.split('@').first
  end

  def create_session_token
    self.session_token = User.digest(User.new_session_token)
  end

  def slug_candidates
    slug = normalize_friendly_id self.name
    # From https://github.com/norman/friendly_id/issues/480
    sequence = User.where("slug LIKE ?", "#{slug}-%").size + 2
    [slug, "#{slug} #{sequence}"]
  end

  def profile_picture_format
    return unless profile_picture.attached?
    return if profile_picture.blob.content_type.start_with? 'image/'

    profile_picture.purge_later
    errors.add(:profile_picture, 'needs to be an image')
  end

  def format_number
    self.phone_number = Phonelib.parse(self.phone_number).sanitized
  end
end
