# frozen_string_literal: true

class SendyService
  include Singleton

  ACTIVE_USERS = "N2hCCSUL9faQIdPHrSU7vg"
  HS_USERS = "mfwYqRfwH0EA4xo7636vwOzA"
  HS_HACKATHONS = "KinDmujRqyB2d9ecewAxeA"
  ROBOTICS_TEAM = "sRQ5J1ZpTnMIP1ZsMJhpCg"
  ADULT_USERS = "jyyAKNEGz8hqHsyLjLNT4Q"

  def subscribe(email:, list_id:)
    put "Subscribing #{email} to list #{list_id}"

    return unless Rails.env.production?

    request("subscribe", :post,
            email: email,
            list: list_id,
            silent: true,
            boolean: true)
  end

  def remove_subscription(email:, list_id:)
    return unless Rails.env.production?

    result = request("api/subscribers/delete.php", :post,
                     email: email,
                     list_id: list_id)

    result.body == 1.to_s
  end

  private

  class NotFoundError < StandardError; end
  class NetworkError < StandardError; end

  def request(path, method, body)
    conn = Faraday.new(url: "https://postal.hackclub.com/")
    resp = conn.send(method) do |req|
      req.url(path)
      req.body = body.merge(api_key: Rails.application.credentials.sendy_api_key)
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    raise NotFoundError if resp.status == 404
    raise NetworkError, "Error POSTing to Sendy. HTTP status: #{resp.status}" unless (200..399).include?(resp.status)

    resp
  end

end
