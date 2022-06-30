# frozen_string_literal: true

module Api
  module Entities
    class User < Base
      include UsersHelper # for `profile_picture_for`

      when_expanded do
        expose :full_name
        expose :photo do |user, options|
          profile_picture_for user
        end
      end

      unexpose :href # Users don't have a `get` endpoint (they can't a resource in our v3 API)

    end
  end
end
