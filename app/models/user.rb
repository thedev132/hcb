class User < ApplicationRecord
  scope :admin, -> { where.not(admin_at: nil) }

  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :events, through: :organizer_positions
  has_many :managed_events, inverse_of: :point_of_contact
  has_many :g_suite_applications, inverse_of: :creator
  has_many :g_suite_applications, inverse_of: :fulfilled_by
  has_many :g_suite_accounts, inverse_of: :fulfilled_by
  has_many :g_suite_accounts, inverse_of: :creator
  has_many :load_card_requests
  has_many :card_requests
  has_many :cards
  has_many :comments, as: :commentable

  before_create :create_session_token

  validates_presence_of :api_id, :api_access_token, :email
  validates_uniqueness_of :api_id, :api_access_token, :email
  validates :phone_number, phone: { allow_blank: true }

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

  def pretty_phone_number
    Phonelib.parse(self.phone_number).national
  end

  private

  def create_session_token
    self.session_token = User.digest(User.new_session_token)
  end
end
