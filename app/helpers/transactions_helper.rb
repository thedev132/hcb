module TransactionsHelper
  def transactions_have_expensify?(t = @transactions)
    t.pluck(:name)&.join(' ')&.downcase&.include?('expensify')
  end
end
