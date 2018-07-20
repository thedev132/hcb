module ApplicationHelper
  include ActionView::Helpers
  def render_money(amount, unit = '$')
    number_to_currency(BigDecimal.new(amount || 0) / 100, unit: unit)
  end

  def render_percentage(decimal, params={})
    precision = params[:precision] || 2
    number_to_percentage(decimal * 100, precision: precision)
  end

  def blankslate(text, options={})
    content_tag :p, text, class: "center mt0 mb0 pt2 pb2 slate bold h3 #{options.class}"
  end

  def badge_for(count)
    content_tag :span, count, class: "badge #{'bg-muted' if count == 0}"
  end

  def status_badge(type = :pending)
    content_tag :span, '', class: "status bg-#{type}"
  end

  def status_if(type, condition)
    status_badge(type) if condition
  end

  def auto_link_new_tab(text)
    auto_link(text, html: { target: '_blank' })
  end
end
