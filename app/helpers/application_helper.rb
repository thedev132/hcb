module ApplicationHelper
  def render_money(amount, unit = '$')
    number_to_currency(BigDecimal.new(amount || 0) / 100, unit: unit)
  end

  def render_percentage(decimal, params={})
    precision = params[:precision] || 2

    number_to_percentage(decimal * 100, precision: precision)
  end
end
