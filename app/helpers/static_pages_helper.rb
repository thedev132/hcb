module StaticPagesHelper
  def card_to(name, path, options = {})
    badge = options[:badge].to_i > 0 ? badge_for(options[:badge]) : ''
    link_to content_tag(:li,
      [content_tag(:strong, name), badge].join.html_safe,
      class: 'card card--item'),
      path, method: options[:method]
  end
end
