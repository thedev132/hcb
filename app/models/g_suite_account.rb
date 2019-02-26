class GSuiteAccount < ApplicationRecord
  include Rejectable

  after_update :notify_user_of_password_change

  belongs_to :g_suite
  belongs_to :creator, class_name: 'User'

  validates_presence_of :address, :backup_email, :first_name, :last_name

  validate :status_accepted_or_rejected
  validates :address, uniqueness: { scope: :g_suite }

  scope :under_review, -> { where(rejected_at: nil, accepted_at: nil) }

  def status
    return 'rejected' if rejected_at.present?
    return 'accepted' if accepted_at.present?
    return 'verified' if verified_at.present?
    'pending'
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

  private

  def notify_user_of_password_change
    return unless saved_change_to_initial_password?

    if initial_password.present?
      email_params = {
        recipient: backup_email,
        address: address,
        password: initial_password
      }

      creator_email_params = {
        recipient: creator.email,
        first_name: first_name,
        last_name: last_name 
      }

      if initial_password_before_last_save.nil?
        GSuiteAccountMailer.notify_user_of_activation(email_params).deliver_later
        GSuiteAccountMailer.notify_creator_of_activation(creator_email_params).deliver_later
      else
        GSuiteAccountMailer.notify_user_of_reset(email_params).deliver_later
      end
    end
  end
end
