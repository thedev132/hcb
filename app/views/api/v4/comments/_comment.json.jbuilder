# frozen_string_literal: true

json.id comment.public_id
json.created_at comment.created_at
json.user comment.user, partial: "api/v4/users/user", as: :user
json.content comment.content

if comment.admin_only
  json.admin_only true
end
