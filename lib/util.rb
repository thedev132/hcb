# frozen_string_literal: true

module Util
  # converts unixtime to datetime
  #
  # really dumb... but this seems to be the best way to convert unixtime to
  # datetime w/o timezone issues. see https://stackoverflow.com/a/7819254.
  def self.unixtime(unixtime)
    DateTime.strptime(unixtime.to_s, "%s")
  end

  def self.average(array)
    array.sum / array.length
  end

  # also in ApplicationHelper for frontend use
  def self.commit_hash
    @commit_hash ||= begin
      ENV["HEROKU_SLUG_COMMIT"] || `git show --pretty=%H -q`&.chomp
    end

    @commit_hash
  end
end
