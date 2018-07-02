class User < ApplicationRecord
  has_many :organizer_position_invites
  has_many :organizer_positions
  has_many :events, through: :organizer_positions
  has_many :load_card_requests
  has_many :card_requests
  has_many :cards
  has_many :comments, as: :commentable

  before_create :create_session_token

  validates_presence_of :api_id, :api_access_token, :email
  validates_uniqueness_of :api_id, :api_access_token, :email

  def self.new_session_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def admin_at
    api_record[:admin_at]
  end

  def admin?
    self.admin_at.present?
  end

  def api_record
    @api_record ||= ApiService.get_user(self.api_id, self.api_access_token)
  end

  private

  def create_session_token
    self.session_token = User.digest(User.new_session_token)
  end
end
