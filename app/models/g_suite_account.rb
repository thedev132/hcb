class GSuiteAccount < ApplicationRecord
  belongs_to :g_suite

  validates_presence_of :address

  validate uniqueness_of_address_in_domain

  def verified?
    verified_at.present?
  end

  private

  def uniqueness_of_address_in_domain
    g_suite.g_suite_accounts.where(address: address).each do |account|
      errors.add(:unique_error, 'Address already in use') if id != account.id
    end
  end
end
