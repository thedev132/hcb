class User < ApplicationRecord
  validates_uniqueness_of :api_access_token

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
end
