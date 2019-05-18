class ApiService
  BASE_URL = 'https://api.hackclub.com'

  class UnauthorizedError < StandardError; end

  def self.req(method, path, params, access_token = nil, raise_on_unauthorized: true)
    conn = Faraday.new(url: BASE_URL)

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
      JSON.parse(resp.body, symbolize_names: true)
    end
  end

  def self.request_login_code(email)
    req(:post, '/v1/users/auth', { email: email })
  end

  def self.exchange_login_code(user_id, login_code)
    req(
      :post,
      "/v1/users/#{user_id}/exchange_login_code",
      { login_code: login_code },
      raise_on_unauthorized: false # 401 just means invalid login code in our case
    )
  end

  def self.get_user(user_id, access_token)
    req(:get, "/v1/users/#{user_id}", nil, access_token)
  end
end
