class UsersController < ApplicationController
  # view to log in
  def auth
  end

  # post to request login code
  def login_code
    email = params[:email]

    resp = ApiService.request_login_code(email)

    @user_id = resp[:id]
  end

  # post to exchange auth token for access token
  def exchange_login_code
    login_code = params[:login_code].gsub('-', '')
    user_id = params[:user_id]

    resp = ApiService.exchange_login_code(user_id, login_code)

    u = User.find_or_initialize_by(api_id: user_id)
    u.api_access_token = resp[:auth_token]

    u.save

    redirect_to u
  end

  def show
    @user = User.find(params[:id])
  end
end
