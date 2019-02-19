module CardsHelper
  def one_isnt_completed?(emburse_transactions) 
    emburse_transactions.collect { |a| !a.completed? }.include?(true)
  end
end
