class ApiService
  BASE_URL = 'https://api.hackclub.com'
  include Util

  class UnauthorizedError < StandardError; end

  def self.req(method, path, params, access_token = nil, raise_on_unauthorized: true)
    ua = "Hack Club Bank (#{Util.commit_hash rescue ''})"
    conn = Faraday.new(url: BASE_URL, headers: { user_agent: ua })

    resp = conn.send(method) do |req|
      req.url path
      req.headers['Content-Type'] = 'application/json'

      if access_token
        req.headers['Authorization'] = "Bearer #{access_token}"
      end

      req.body = params.to_json
    end

    if resp.status == 401 && raise_on_unauthorized
      raise UnauthorizedError.new
    else
      begin
        JSON.parse(resp.body, symbolize_names: true)
      rescue JSON::ParserError
        raise UnauthorizedError.new
      end
    end
  end
end
