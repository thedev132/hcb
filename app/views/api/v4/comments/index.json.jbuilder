# frozen_string_literal: true

json.array! @comments, partial: "api/v4/comments/comment", as: :comment
