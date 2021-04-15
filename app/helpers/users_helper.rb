require 'digest/md5'
require 'uri'

module UsersHelper
  def gravatar_url(email, name, id, size)
    name ||= email
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{URI.encode(name)}/#{size}/#{get_user_color(id)}/fff"
  end

  def avatar_for(user, size = 24, options = {})
    # avatar_for works with OpenStructs (used on the front end when a user isn't registered),
    # so this method shows Gravatars/intials for non-registered and allows showing of uploaded profile pictures for registered users.
    if !Rails.env.development? && (user.is_a?(User) && user&.profile_picture.attached?)
      src = user.profile_picture.variant(combine_options: {
        thumbnail: "#{size * 2}x#{size * 2}^",
        gravity: 'center',
        extent: "#{size * 2}x#{size * 2}" })
    else
      src = gravatar_url(user.email, user.initials, user.id, size * 2)
    end

    image_tag(src, options.merge({ loading: 'lazy', alt: user.name, width: size, height: size, class: "circle shrink-none #{options[:class]}" }))
  end

  def user_mention(user, options = {})
    avi = avatar_for user
    name = content_tag :span, user.initial_name
    if user.admin?
      bolt = inline_icon 'admin-badge', size: 20
      content_tag :span,
                  avi + bolt + name,
                  class: "mention mention--admin tooltipped tooltipped--n #{options[:class]}",
                  'aria-label': "#{user.name.split(' ').first} is an admin"
    else
      content_tag :span, avi + name, class: "mention #{options[:class]}"
    end
  end

  def admin_tools(class_name = '', element = 'div', &block)
    return unless current_user&.admin?

    concat("<#{element} class='admin-tools #{class_name}'>".html_safe)
    yield
    concat("</#{element}>".html_safe)
  end

  def creator_bar(object, options = {})
    creator = defined?(object.creator) ? object.creator :
      defined?(object.sender) ? object.sender : object.user
    mention = creator ? user_mention(creator) : content_tag(:strong, 'Anonymous')
    content_tag :div, class: 'comment__name' do
      mention + relative_timestamp(object.created_at, prefix: options[:prefix], class: 'h5 muted')
    end
  end

  private

  def get_user_color(id)
    alphabet = ('A'..'Z').to_a
    colors = ['ec3750', 'ff8c37', 'f1c40f', '33d6a6', '5bc0de', '338eda']
    colors[id.to_i % colors.length] || colors.last
  end
end
