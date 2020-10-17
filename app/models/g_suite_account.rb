class GSuiteAccount < ApplicationRecord
  include Rejectable

  after_update :attempt_notify_user_of_password_change

  paginates_per 50

  belongs_to :g_suite
  belongs_to :creator, class_name: 'User'

  validates_presence_of :address, :backup_email, :first_name, :last_name

  validate :status_accepted_or_rejected
  validates :address, uniqueness: { scope: :g_suite }

  before_update :sync_update_to_gsuite

  before_destroy :sync_delete_to_gsuite

  scope :under_review, -> { where(rejected_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'suspended' if suspended_at.present?
    return 'accepted' if accepted_at.present?
    return 'verified' if verified_at.present?

    'pending'
  end

  def suspended?
    suspended_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def under_review?
    rejected_at.nil? && accepted_at.nil?
  end

  def verified?
    verified_at.present?
  end

  def username
    address.to_s.split('@').first
  end

  def at_domain
    "@#{address.to_s.split('@').last}"
  end

  def event
    g_suite.event
  end

  def reset_password!
    if Rails.env.development?
      puts "☣️ In production, we would currently be syncing the GSuite account password reset ☣️"
      return
    end

    # new 12-character password
    password = SecureRandom.hex(6)

    # ask GSuite to reset
    GsuiteService.instance.reset_gsuite_user_password(address, password)

    self.initial_password = password
    self.save
  end

  def toggle_suspension!
    if self.suspended_at.nil?
      self.suspended_at = DateTime.now
    else
      self.suspended_at = nil
    end

    self.save
  end

  private

  def notify_user_of_password_change(first_password = false)
    email_params = {
      recipient: backup_email,
      address: address,
      password: initial_password,
      event: g_suite.event.name,
    }

    creator_email_params = {
      recipient: creator.email,
      first_name: first_name,
      last_name: last_name,
      event: g_suite.event.name,
    }

    if first_password
      GSuiteAccountMailer.notify_user_of_activation(email_params).deliver_later
    else
      GSuiteAccountMailer.notify_user_of_reset(email_params).deliver_later
    end
  end

  def sync_delete_to_gsuite
    if Rails.env.development?
      puts "☣️ In production, we would currently be syncing the GSuite account deletion ☣️"
      return
    end

    if !GsuiteService.instance.delete_gsuite_user(address)
      errors.add(self, "couldn't be deleted from GSuite!")
      throw :abort
    end
  end

  def sync_update_to_gsuite
    return unless suspended_at_changed?

    if Rails.env.development?
      puts "☣️ In production, we would currently be syncing the GSuite account suspension ☣️"
      return
    end

    if suspended_at.nil?
      GsuiteService.instance.toggle_gsuite_user_suspension(address, false)
    else
      GsuiteService.instance.toggle_gsuite_user_suspension(address, true)
    end
  end

  def attempt_notify_user_of_password_change
    return unless saved_change_to_initial_password?

    if initial_password.present?
      if initial_password_before_last_save.nil?
        notify_user_of_password_change(true)
      else
        notify_user_of_password_change
      end
    end
  end
end
