class GSuiteAccount < ApplicationRecord
  belongs_to :g_suite
  belongs_to :creator, class_name: 'User'

  validates_presence_of :address

  validate :uniqueness_of_address_in_domain

  def status
    return 'rejected' if rejected_at.present?
    return 'accepted' if accepted_at.present?
    return 'verified' if verified_at.present?
    'under review'
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

  def uniqueness_of_address_in_domain
    g_suite.g_suite_accounts.where(address: address).each do |account|
      errors.add(:unique_error, 'Address already in use') if id != account.id
    end
  end
end
