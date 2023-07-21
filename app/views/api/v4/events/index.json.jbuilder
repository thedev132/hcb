# frozen_string_literal: true

json.array! @events do |event|
  json.partial! event

  json.users event.users, partial: "api/v4/users/user", as: :user
end
