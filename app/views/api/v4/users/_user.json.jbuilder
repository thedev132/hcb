# frozen_string_literal: true

json.id user.public_id
json.name user.name
json.email user.email
json.avatar user.profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(user.profile_picture) : nil
json.admin user.admin?
