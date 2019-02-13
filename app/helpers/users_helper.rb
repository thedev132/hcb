require 'digest/md5'
require 'uri'

module UsersHelper
  def gravatar_url(email, name, size)
    name ||= email
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{URI.encode(name)}/#{size}/e42d42/fff"
  end

  def avatar_for(user, size = 24, options = {})
    image_tag gravatar_url(user.email, user.initials, size * 2),
      options.merge({ alt: user.name, width: size, height: size, class: "circle #{options[:class]}" })
  end

  def user_mention(user)
    avi = avatar_for user
    name = content_tag :span, user.name
    content_tag :span, avi + name, class: 'mention'
  end

  def admin_tools(class_name = '', &block)
    return unless current_user.admin?
    concat("<div class='admin-tools #{class_name}'>".html_safe)
      yield
    concat('</div>'.html_safe)
  end

  def creator_bar(object)
    creator = defined?(object.creator) ? object.creator : object.user
    content_tag :div, class: 'comment__name' do
      user_mention(creator) + relative_timestamp(object.created_at, class: 'h5 muted')
    end
  end
end
