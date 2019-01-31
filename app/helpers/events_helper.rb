module EventsHelper
  def dock_card(name, icon, color, url)
    link_to url, class: 'card' do
      inline_icon(icon, size: 32, class: color) + content_tag(:span, name)
    end
  end
end
