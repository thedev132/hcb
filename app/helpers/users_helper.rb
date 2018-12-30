require 'digest/md5'
require 'uri'

module UsersHelper
  def gravatar_url(email, name, size = 64)
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{URI.encode(name)}/#{size}/e42d42/fff"
  end

  def gravatar_for(user, size, options = {})
    image_tag gravatar_url(user.email, user.name, size), options
  end

  def user_mention(user)
    avi = gravatar_for user, 48
    name = content_tag :span, user.name
    content_tag :span, avi + name, class: 'mention'
  end
end
