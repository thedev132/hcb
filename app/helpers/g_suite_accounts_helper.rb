# frozen_string_literal: true

module GSuiteAccountsHelper
  def one_has_password?(accounts)
    accounts.collect { |a| a.initial_password.present? }.include?(true)
  end
end
