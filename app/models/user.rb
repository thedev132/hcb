class User < ApplicationRecord
  has_many :organizer_positions
  has_many :events, through: :organizer_positions

  before_create :create_session_token

  validates_uniqueness_of :api_access_token

  def self.new_session_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def email
    api_record[:email]
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
