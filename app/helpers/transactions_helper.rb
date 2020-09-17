module TransactionsHelper
  def transactions_have_expensify?(t = @transactions)
    t.map(&:name).join(' ').downcase.include?('expensify')
  end
end
