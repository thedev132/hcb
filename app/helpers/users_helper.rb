# frozen_string_literal: true

require "digest/md5"
require "cgi"

module UsersHelper
  def gravatar_url(email, name, id, size)
    name ||= email
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{CGI.escape(name)}/#{size}/#{get_user_color(id)}/fff"
  end

  def avatar_for(user, size = 24, options = {})
    # avatar_for works with OpenStructs (used on the front end when a user isn't registered),
    # so this method shows Gravatars/intials for non-registered and allows showing of uploaded profile pictures for registered users.
    if Rails.env.production? && (user.is_a?(User) && user&.profile_picture.attached?)
      src = user.profile_picture.variant(combine_options: {
        thumbnail: "#{size * 2}x#{size * 2}^",
        gravity: "center",
        extent: "#{size * 2}x#{size * 2}" })
    else
      src = gravatar_url(user.email, user.initials, user.id, size * 2)
    end

    klasses = ["circle", "shrink-none"]
    klasses << "avatar--current-user" if user == current_user
    klasses << options[:class] if options[:class]
    klass = klasses.join(" ")

    image_tag(src, options.merge({ loading: "lazy", alt: user.name, width: size, height: size, class: klass }))
  end

  def user_mention(user, options = {})
    avi = avatar_for user
    name = content_tag :span, user.initial_name

    klasses = ["mention"]
    klasses << %w[mention--admin tooltipped tooltipped--n] if user.admin?
    klasses << "mention--current-user" if user == current_user
    klasses << options[:class] if options[:class]
    klass = klasses.join(" ")

    aria = if user == current_user
      [
        "You!",
        "Yourself!",
        "It's you!"
      ].sample
    elsif user.admin?
      "#{user.name.split(' ').first} is an admin"
    end

    content = if user.admin?
      bolt = inline_icon "admin-badge", size: 20
      avi + bolt + name
    else
      avi + name
    end

    content_tag :span, content, class: klass, 'aria-label': aria
  end

  def admin_tools(class_name = "", element = "div", &block)
    return unless current_user&.admin?

    concat("<#{element} class='admin-tools #{class_name}'>".html_safe)
    yield
    concat("</#{element}>".html_safe)
  end

  def creator_bar(object, options = {})
    creator = defined?(object.creator) ? object.creator :
      defined?(object.sender) ? object.sender : object.user
    mention = creator ? user_mention(creator) : content_tag(:strong, "Anonymous")
    content_tag :div, class: "comment__name" do
      mention + relative_timestamp(object.created_at, prefix: options[:prefix], class: "h5 muted")
    end
  end

  private

  def get_user_color(id)
    alphabet = ("A".."Z").to_a
    colors = ["ec3750", "ff8c37", "f1c40f", "33d6a6", "5bc0de", "338eda"]
    colors[id.to_i % colors.length] || colors.last
  end
end
