module EmburseClient
  class NotFoundError < StandardError; end

  def self.request(path, method = :get, body = nil, headers = nil)
    conn = Faraday.new(url: 'https://api.emburse.com/')

    resp = conn.send(method) do |req|
      req.url(path)
      req.body = body.to_json if %i{post put}.include? method
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Token #{access_token}"
    end

    raise NotFoundError if resp.status === 404

    JSON.parse(resp.body, symbolize_names: true)
  end

  def self.request_paginated(path)
    next_url = path
    result = []
    while !next_url.nil? do
      resp = self.request next_url
      result += resp[:results] unless resp[:results].blank?
      if resp[:next].nil?
        next_url = nil
      else
        next_url = resp[:next].sub('https://api.emburse.com/', '')
      end
    end

    result
  end

  private

  def self.access_token
    Rails.application.credentials.emburse[:access_token]
  end
end
