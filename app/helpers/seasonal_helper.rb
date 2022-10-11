# frozen_string_literal: true

module SeasonalHelper
  SEASONS = {
    # format:
    # [[start_month, start_day], [end_month, end_day]]

    fall: [[10, 1], [10, 31]],
    winter: [[12, 1], [12, 31]],
  }.freeze

  SEASONS.each do |key, value|
    define_method "#{key}?" do
      today = Date.today
      low = SEASONS[key][0]
      high = SEASONS[key][1]

      today.day.between?(low[1], high[1]) && today.month.between?(low[0], high[0])
    end
  end

  def by_season(default, hash)
    hash.each do |key, value|
      return value if send("#{key}?")
    end

    return default
  end

  def current_season
    SEASONS.each do |key, value|
      return key if send("#{key}?")
    end

    nil
  end
end
