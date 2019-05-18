class MarkdownService
  include Singleton

  def renderer
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true), tables: true, autolink: true)
  end
end
