# frozen_string_literal: true

module ReceiptService
  class Extract
    def initialize(receipt:)
      @receipt = receipt.reload
    end

    def run!
      if @receipt.textual_content.nil?
        @textual_content = @receipt.extract_textual_content!
        return nil if @textual_content.nil?
      else
        @textual_content = @receipt.textual_content
      end

      {
        amount_cents: amount_cents,
        card_last_four: card_last_four,
        date: date,
        textual_content: @textual_content
      }
    end

    private

    def match_regex(regex, text, &block)
      matches = if block_given?
                  text.scan(regex).map { |match| block.call(match) }
                else
                  text.scan(regex)
                end

      positions = text.enum_for(:scan, regex).map { Regexp.last_match.begin(0) }

      matches.map.with_index do |match, index|
        position = positions[index]
        before_fragment = index == 0 ? text[0..(position - 1)] : text[(positions[index - 1] + matches[index - 1].to_s.length)..(position - 1)]
        after_fragment = index == matches.length - 1 ? text[(position + match.to_s.length)..] : text[(position + match.to_s.length)..(positions[index + 1] - 1)]

        {
          before_fragment: before_fragment,
          match: match,
          position: position,
          after_fragment: after_fragment
        }
      end
    end

    def amount_cents
      amount_cents_regex = /\$( ?[\d.,]+)(\s|\n|\\n)/

      amounts = match_regex(amount_cents_regex, @textual_content) { |match| match.first }
      amounts = amounts.map do |match|
        match[:amount] = (match[:match].to_f * 100).to_i

        match
      end

      amounts = amounts.reverse

      amounts.each_with_index do |amount, index|
        if amount[:before_fragment].downcase.include?("total")
          # TODO - Exclude "sub"total
          amounts = [amount] + amounts[0...index] + amounts[index + 1..]
        end
      end

      amounts.map do |amount|
        0 - amount[:amount]
      end
    end

    def card_last_four
      text_regex = /(?:(?:ending ?(?:in|with)?|visa|card|digits|account|credit|debit|number) ?[-–—]? ?:? ?(?:\\n)?)(?:\(?(?<last4>\d{4})\)?)(?:\s|\\n|[^\d]|$)/i
      x_regex = /[*x•·]{1,12}? ?(?:-|—)? ?(?<last4>\d{4})(?:\s|\\n|\)|$)/i

      [
        *match_regex(text_regex, @textual_content) { |match| match.first },
        *match_regex(x_regex, @textual_content) { |match| match.first }
      ].pluck(:match)
    end

    def date
      # TODO - Match written dates

      slash_regex = /(?:(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2,4}))/i
      dash_regex = /(?:(?<month>\d{1,2})-(?<day>\d{1,2})-(?<year>\d{2,4}))/i

      dates = [*match_regex(slash_regex, @textual_content), *match_regex(dash_regex, @textual_content)].map do |match|
        integer_values = match[:match].map(&:to_i)

        month, day, year = integer_values

        [
          [month, day, year],
          [day, month, year],
          [year, month, day]
        ]
      end.flatten(1).reject do |date|
        month, day, year = date

        month > 12 || day > 31 || year < 1000 || year > Time.now.year + 1
      end

    end

  end
end
