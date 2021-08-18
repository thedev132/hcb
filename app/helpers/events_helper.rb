# frozen_string_literal: true

module EventsHelper
  def dock_item(name, tooltip, icon,  url, lg = false)
    link_to url,
      class: "dock__item #{lg && 'dock__item--lg'} tooltipped tooltipped--e",
      'aria-label': tooltip do
      inline_icon(icon, size: 32, class: "primary") + content_tag(:span, name.html_safe, class: "line-height-3")
    end
  end

  def transfers_airtable_form(embed: false, event: nil, user: nil)
    embed_url = "https://airtable.com/embed/shrH9fMs5hof2HRup"
    url = "https://airtable.com/shrH9fMs5hof2HRup"

    prefill = []
    prefill << "prefill_Event/Project+Name=#{event.name}" if event
    prefill << "prefill_Submitter+Name=#{user.full_name}" if user
    prefill << "prefill_Submitter+Email=#{user.email}" if user

    (embed ? embed_url : url) + "?" + prefill.join("&")
  end
end
