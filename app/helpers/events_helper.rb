# frozen_string_literal: true

module EventsHelper
  def dock_item(name, tooltip, icon,  url, lg = false)
    link_to url,
      class: "dock__item #{lg && 'dock__item--lg'} tooltipped tooltipped--e",
      'aria-label': tooltip do
      inline_icon(icon, size: 32, class: "primary") + content_tag(:span, name.html_safe, class: "line-height-3")
    end
  end
end
