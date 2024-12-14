# frozen_string_literal: true

class User
  class UpdateTeenagerColumnJob < ApplicationJob
    queue_as :low

    def perform
      User.all.find_each(batch_size: 100) do |user|
        user.update(teenager: !!user.birthday&.after?(19.years.ago))
      end
    end

  end

end
