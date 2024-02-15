# frozen_string_literal: true

json.id comment.id
json.created_at comment.created_at
json.user comment.user, partial: "api/v4/users/user", as: :user
json.content comment.content

if @current_user.admin?
  json.admin_only comment.admin_only
end
