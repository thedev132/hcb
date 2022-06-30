# frozen_string_literal: true

require "digest/md5"
require "cgi"

module UsersHelper
  def gravatar_url(email, name, id, size)
    name ||= email
    hex = Digest::MD5.hexdigest(email.downcase.strip)
    "https://gravatar.com/avatar/#{hex}?s=#{size}&d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{CGI.escape(name)}/#{size}/#{get_user_color(id)}/fff"
  end

  def profile_picture_for(user, size = 24)
    # profile_picture_for works with OpenStructs (used on the front end when a user isn't registered),
    # so this method shows Gravatars/intials for non-registered and allows showing of uploaded profile pictures for registered users.
    if user.nil?
      src = "https://cloud-80pd8aqua-hack-club-bot.vercel.app/0image-23.png"
    elsif Rails.env.production? && (user.is_a?(User) && user&.profile_picture.attached?)
      src = Rails.application.routes.url_helpers.url_for(user.profile_picture.variant(
                                                           thumbnail: "#{size * 2}x#{size * 2}^",
                                                           gravity: "center",
                                                           extent: "#{size * 2}x#{size * 2}"
                                                         ))
    else
      src = gravatar_url(user.email, user.initials, user.id, size * 2)
    end

    src
  end

  def avatar_for(user, size = 24, options = {})
    src = profile_picture_for(user, size)

    klasses = ["circle", "shrink-none"]
    klasses << "avatar--current-user" if user == current_user
    klasses << options[:class] if options[:class]
    klass = klasses.join(" ")

    image_tag(src, options.merge(loading: "lazy", alt: user&.name || "Brown dog grinning and gazing off into the distance", width: size, height: size, class: klass))
  end

  def user_mention(user, options = {}, default_name = "No User")
    if user.nil?
      name = content_tag :span, default_name
    else
      name = content_tag :span, user.initial_name
    end

    avi = avatar_for user

    klasses = ["mention"]
    klasses << %w[mention--admin tooltipped tooltipped--n] if user&.admin?
    klasses << "mention--current-user" if user == current_user
    klasses << options[:class] if options[:class]
    klass = klasses.join(" ")

    aria = if user.nil?
             "No user found"
           elsif user == current_user
             [
               "You!",
               "Yourself!",
               "It's you!",
               "Someone you used to know!",
               "You probably know them!",
               "You’re currently looking in a mirror",
               "it u!",
               "Long time no see!",
               "You look great!",
               "Your best friend",
               "Hey there, big spender!",
               "Yes, you!",
               "Who do you think you are?!",
               "Who? You!",
               "You who!"
             ].sample
           elsif user&.admin?
             "#{user.name.split(' ').first} is an admin"
           end

    content = if user&.admin?
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
    creator = if defined?(object.creator)
                object.creator
              elsif defined?(object.sender)
                object.sender
              else
                object.user
              end
    mention = user_mention(creator, options, default_name = "Anonymous User")
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
