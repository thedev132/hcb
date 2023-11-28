# frozen_string_literal: true

module ReceiptService
  class Suggest
    def initialize(receipt:)
      @receipt = receipt
    end

    def run!(include_details: false)
      return nil if user.nil?
      return nil unless @receipt.has_textual_content?

      @extracted = ::ReceiptService::Extract.new(receipt: @receipt).run!

      transaction_distances(include_details:)
    end

    def self.weights
      {
        amount_cents: 1,
        date: 1000,
        card_last_four: 1000,
        merchant_zip_code: 500,
        merchant_city: 500,
        merchant_phone: 500,
        merchant_name: 500
      }
    end

    def sorted_transactions
      transaction_distances.sort_by { |match| match[:distance] }
    end

    def best_match
      sorted_transactions.first
    end

    private

    def transaction_distances(include_details: false)
      potential_txns.map do |txn|
        {
          hcb_code: txn,
          distance: distance(txn),
          details: include_details ? distances_hash(txn) : nil
        }
      end
    end

    def safe_date(month, day, year)
      begin
        Date.new(year, month, day)
      rescue Date::Error => e
        nil
      end
    end

    def distances_hash(txn)
      distances = {
        card_last_four: @extracted[:card_last_four].include?(txn.stripe_card.last4) ? 0 : 1,
        merchant_zip_code: if txn.stripe_merchant["postal_code"].nil?
                             nil
                           else
                             (@extracted[:textual_content].include?(txn.stripe_merchant["postal_code"]) ? 0 : 1)
                           end,
        merchant_city: if txn.stripe_merchant["city"].nil?
                         nil
                       else
                         (@extracted[:textual_content].downcase.include?(txn.stripe_merchant["city"].downcase) ? 0 : 1)
                       end,
        merchant_phone: if txn.stripe_merchant["city"].nil?
                          nil
                        else
                          (txn.stripe_merchant["city"].gsub(/\D/, "").length > 6 && @extracted[:textual_content].include?(txn.stripe_merchant["city"].gsub(/\D/, "")) ? 0 : 1)
                        end,
        merchant_name: if txn.stripe_merchant["name"].nil?
                         nil
                       else
                         @extracted[:textual_content].downcase.include?(txn.stripe_merchant["name"].downcase) ? 0 : 1
                       end
      }

      if @extracted[:amount_cents].include?(txn.amount_cents)
        distances[:amount_cents] = @extracted[:amount_cents].index(txn.amount_cents) * 3
      else
        distances[:amount_cents] = best_distance(txn.amount_cents, @extracted[:amount_cents].take(2))
      end

      distances[:date] =
        if @extracted[:date].empty?
          nil
        else
          best_distance(txn.date.to_time.to_i / 86400, @extracted[:date].map { |d| safe_date(*d) }.reject { |d| d.nil? }.map{ |d| d.to_time.to_i / 86400 })
        end

      distances
    end

    def distance(txn)
      distances = distances_hash(txn)

      total_weight = self.class.weights.values.sum
      weight_applied = 0
      distance = 0

      self.class.weights.each do |key, weight|
        unless distances[key].nil?
          weight_applied += weight
          distance += (distances[key] * weight)**2
        end
      end

      # distance formula options

      # euclidian distance
      # Math.sqrt(amount_cents**2 + date**2 + card_last_four**2)

      # manhattan distance
      # (amount_cents**1 + date**1 + card_last_four**1)**(1/1)

      # chebyshev distance
      # [amount_cents, date, card_last_four].max

      # minkowski distance
      # (amount_cents**3 + date**3 + card_last_four**3)**(1.0/3.0)

      distance *= (total_weight / weight_applied) # scale up to account for missing weights

      Math.sqrt(distance)
    end

    def best_distance(one_point, multiple_values)
      multiple_values.map do |value|
        (one_point - value).abs
      end.min || 100
    end

    def user
      @receipt.user
    end

    def potential_txns
      user.stripe_cards.flat_map(&:hcb_codes).select { |hcb_code| hcb_code.needs_receipt? }
    end

  end
end
