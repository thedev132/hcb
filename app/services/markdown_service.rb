# frozen_string_literal: true

class MarkdownService
  include Singleton

  class MarkdownRenderer < Redcarpet::Render::HTML
    include ApplicationHelper # for render_money helper

    def link(link, title, alt_text)
      link_to alt_text, link, title: title,
                              target: "_blank"
    end

    def autolink(link, link_type)
      try_card_autolink(link) or
        try_hcb_autolink(link) or
        try_event_autolink(link) or
        link_to link, link, title: link_type
    end

    def image(link, title, alt_text)
      image_tag link, title: title || alt_text,
                      alt: alt_text,
                      style: 'width: 100%;'
    end

    private

    def try_event_autolink(link)
      found_event = link.match(/(#{app_hosts.join('|')})\/([\w|-]*)$/)

      if found_event
        event_id = found_event[2]
        event = Event.find_by_slug(event_id) || Event.find_by_id(event_id)

        return nil unless event

        link_to event.slug.to_s, link, target: "_blank", class: "autolink"
      end
    end

    def try_card_autolink(link)
      found_card = link.match(/(#{app_hosts.join('|')})\/stripe_cards\/(\d*)/)

      if found_card
        card_id = found_card[2]
        card = StripeCard.find_by_id card_id
        event = card&.event
        return nil unless card && event

        link_to "#{card.status_text.downcase} card (#{card.user.first_name})",
                link,
                target: "_blank",
                class: "tooltipped tooltipped--e autolink",
                'aria-label' => card.status_text.to_s
      end
    end

    def try_hcb_autolink(link)
      found_link = link.match(/(#{app_hosts.join('|')})\/hcb\/(\w{5,6})\#comment-(\w{5,6})/)
      found_link ||= link.match(/(#{app_hosts.join('|')})\/hcb\/(\w{5,6})/)

      if found_link
        hcb_code = found_link[2]
        comment = found_link[3]
        hcb = HcbCode.find_by_hashid hcb_code
        link_to "#{'comment on ' unless comment.blank?}#{hcb.humanized_type.downcase} (HCB-#{hcb.hashid})",
                link,
                target: "_blank",
                class: "tooltipped tooltipped--e autolink",
                'aria-label' => "#{render_money hcb.amount_cents} - #{hcb.memo}"
      else
        return nil
      end
    end

    def app_hosts
      hosts = []
      hosts << Rails.application.credentials.default_url_host[:live]
      hosts << Rails.application.credentials.default_url_host[:test] if Rails.env.development?

      hosts.map { |h| Regexp.escape h }
    end

  end

  def renderer
    markdown_renderer = MarkdownRenderer.new(hard_wrap: true,
                                             filter_html: true)
    Redcarpet::Markdown.new(markdown_renderer, strikethrough: true,
                                               tables: true,
                                               autolink: true)
  end

end
