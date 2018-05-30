module ApplicationHelper
  def render_money(amount)
    number_to_currency(BigDecimal.new(amount) / 100)
  end
end
