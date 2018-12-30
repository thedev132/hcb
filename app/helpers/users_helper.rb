require 'digest/md5'
require 'uri'

module UsersHelper
  def gravatar_url(email, name, size)
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{URI.encode(name)}/#{size}/e42d42/fff"
  end

  def avatar_for(user, size = 32, options = {})
    image_tag gravatar_url(user.email, user.name, size * 2), options.merge({ alt: user.name, width: size, class: "circle #{options[:class]}" })
  end

  def user_mention(user)
    avi = avatar_for user, 24
    name = content_tag :span, user.name
    content_tag :span, avi + name, class: 'mention'
  end
end
