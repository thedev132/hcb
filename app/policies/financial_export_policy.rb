class FinancialExportPolicy < ApplicationPolicy
  def financial_export?
    user.admin?
  end
end
