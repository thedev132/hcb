module ApplicationHelper
  include ActionView::Helpers
  def render_money(amount, unit = '$')
    number_to_currency(BigDecimal.new(amount || 0) / 100, unit: unit)
  end

  def render_money_short(amount, unit = '$')
    render_money(amount, unit).remove('.00')
  end

  def render_percentage(decimal, params = {})
    precision = params[:precision] || 2
    number_to_percentage(decimal * 100, precision: precision)
  end

  def blankslate(text, options = {})
    other_options = options.except(:class)
    content_tag(:p, text, class: "center mt0 mb0 pt2 pb2 slate bold h3 mx-auto max-width-2 #{options[:class]}", **other_options)
  end

  def filterbar_blankslate(text, options = {})
    blankslate(text, 'data-behavior': 'filterbar_blankslate', class: 'mt2 mb2', **options)
  end

  def badge_for(count, options = {})
    content_tag :span, count, class: "badge #{options[:class]} #{'bg-muted' if count == 0} #{options[:class]}"
  end

  def status_badge(type = :pending)
    content_tag :span, '', class: "status bg-#{type}"
  end

  def status_if(type, condition)
    status_badge(type) if condition
  end

  def pop_icon_to(icon, url, options = {})
    link_to url, options.merge({ class: "pop #{options[:class]}" }) do
      inline_icon icon, size: 28
    end
  end

  def no_app_shell
    @no_app_shell = true
  end

  def form_errors(model, name = nil, prefix = "We couldn't save this")
    return if model.errors.none?

    name ||= model.class.name.underscore.humanize.downcase

    errors_list = content_tag :ul do
      model.errors.full_messages.map do |message|
        concat(content_tag :li, message)
      end
    end

    content_tag :div, class: 'error-card' do
      content_tag(:h2, "#{prefix} #{name} because of #{pluralize(model.errors.size, 'error')}.") +
        errors_list
    end
  end

  def modal_close
    pop_icon_to 'view-close', '#close_modal', class: 'modal__close muted', rel: 'modal:close', tabindex: 0
  end

  def modal_header(text)
    content_tag :header, modal_close + content_tag(:h2, text.html_safe, class: 'h1 mt0 mb0 pb0 border-none'), class: 'pb2'
  end

  # jQuery plugins are buggy when navigating between pages with Turbolinks.
  # This forces the page to reload when Turbolinks navigates to it
  def include_modals
    content_for :head do
      tag(:meta, name: 'turbolinks-visit-control', content: 'reload')
    end
  end

  def relative_timestamp(time, options = {})
    content_tag :span, "#{options[:prefix]}#{time_ago_in_words time} ago", options.merge({ title: time })
  end

  def auto_link_new_tab(text)
    auto_link(text, html: { target: '_blank' })
  end

  def debug_obj(item)
    content_tag :pre, pp(item.attributes.to_yaml)
  end

  def inline_icon(filename, options = {})
    file = File.read(Rails.root.join('app', 'assets', 'images', 'icons', "#{filename}.svg"))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    options[:style] ||= ''
    if options[:size]
      options[:width] ||= options[:size]
      options[:height] ||= options[:size]
      options.delete :size
    end
    options.each { |key, value| svg[key.to_s] = value }
    doc.to_html.html_safe
  end

  def filterbar_item(label, name, selected = false)
    content_tag :a, label, class: 'filterbar__item',
                           tabindex: 0, role: 'tab', 'aria-selected': selected,
                           data: { name: name.to_s, behavior: 'filterbar_item' }
  end

  def format_date(date)
    local_time(date, '%b %e, %Y')
  end

  def format_datetime(datetime)
    local_time(datetime, '%b %e, %Y, %l:%M %p')
  end

  def home_action_size
    @home_size.to_i > 48 ? 36 : 28
  end

  def page_md
    content_for(:container_class) { 'container--md' }
  end

  def page_sm
    content_for(:container_class) { 'container--sm' }
  end
  alias_method :page_narrow, :page_sm

  def page_xs
    content_for(:container_class) { 'container--xs' }
  end
  alias_method :page_extranarrow, :page_xs

  def title(text)
    content_for :title, text
  end
end
