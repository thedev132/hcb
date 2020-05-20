module EventsHelper
  def dock_card(name, tooltip, icon, color, url)
    link_to url, class: 'dock__card tooltipped tooltipped--n', 'aria-label': tooltip do
      inline_icon(icon, size: 32, class: color) + content_tag(:span, name)
    end
  end
end
