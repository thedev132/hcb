module ApplicationHelper
  def render_money(amount)
    number_to_currency(BigDecimal.new(amount) / 100)
  end

  def render_percentage(decimal, params={})
    precision = params[:precision] || 2

    number_to_percentage(decimal * 100, precision: precision)
  end
end
