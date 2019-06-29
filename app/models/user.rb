class User < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged
  scope :admin, -> { where.not(admin_at: nil) }

  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :events, through: :organizer_positions
  has_many :managed_events, inverse_of: :point_of_contact
  has_many :g_suite_applications, inverse_of: :creator
  has_many :g_suite_applications, inverse_of: :fulfilled_by
  has_many :g_suite_accounts, inverse_of: :fulfilled_by
  has_many :g_suite_accounts, inverse_of: :creator
  has_many :organizer_position_deletion_requests, inverse_of: :submitted_by
  has_many :organizer_position_deletion_requests, inverse_of: :closed_by
  has_many :load_card_requests
  has_many :card_requests
  has_many :cards
  has_many :comments, as: :commentable

  has_one_attached :profile_picture

  before_create :create_session_token

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

  def admin?
    self.admin_at.present?
  end

  def api_record
    ApiService.get_user(self.api_id, self.api_access_token)
  end

  def name
    full_name || email
  end

  def initials
    words = name.split(/[^[[:word:]]]+/)
    words.any? ? words.map(&:first).join.upcase : name
  end

  def pretty_phone_number
    Phonelib.parse(self.phone_number).national
  end

  private

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
end
