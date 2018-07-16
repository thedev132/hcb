module EmburseClient
  def self.request(path, method = :get, body = nil, headers = nil)
    conn = Faraday.new(url: 'https://api.emburse.com/')

    resp = conn.send(method) do |req|
      req.url(path)
      req.body = body.to_json if %i{post put}.include? method
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Token #{access_token}"
    end

    JSON.parse(resp.body, symbolize_names: true)
  end

  private

  def self.access_token
    Rails.application.credentials.emburse[:access_token]
  end
end
