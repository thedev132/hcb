class ApiService
  BASE_URL = 'https://api.hackclub.com'

  class UnauthorizedError < StandardError; end

  def self.req(method, path, params, access_token=nil)
    conn = Faraday.new(url: BASE_URL)

    resp = conn.send(method) do |req|
      req.url path
      req.headers['Content-Type'] = 'application/json'

      if access_token
        req.headers['Authorization'] = "Bearer #{access_token}"
      end

      req.body = params.to_json
    end

    if resp.status == 401
      raise UnauthorizedError.new
    else
      JSON.parse(resp.body, symbolize_names: true)
    end
  end

  def self.request_login_code(email)
    req(:post, '/v1/users/auth', { email: email })
  end

  def self.exchange_login_code(user_id, login_code)
    resp = req(:post, "/v1/users/#{user_id}/exchange_login_code", { login_code: login_code })
  rescue UnauthorizedError # 401 is ok in this method because it means the user just gave a bad login code
    resp
  end

  def self.get_user(user_id, access_token)
    req(:get, "/v1/users/#{user_id}", nil, access_token) 
  end
end
