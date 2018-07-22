class UsersController < ApplicationController
  skip_after_action :verify_authorized, except: [:edit, :update]

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
    @user_id = params[:user_id]
    login_code = params[:login_code].to_s.gsub('-', '').gsub(/\s+/, '')

    resp = ApiService.exchange_login_code(@user_id, login_code)

    if resp[:errors].present?
      flash[:error] = 'Invalid login code'
      return render :login_code
    end

    u = User.find_or_initialize_by(api_id: @user_id)
    u.api_access_token = resp[:auth_token]
    u.email = u.api_record[:email]

    u.save

    sign_in u
    if u.full_name.blank?
      redirect_to edit_user_path(u)
    else
      redirect_back_or root_path
    end
  end

  def logout
    require_auth
    sign_out
    redirect_to root_path
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update(user_params)
      flash[:success] = 'Profile changes saved successfully.'
      redirect_to params[:redirect_to] || root_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email)
  end

  def require_auth
    unless signed_in?
      flash[:error] = 'Not signed in!'
      redirect_to(request.referrer || root_path)
      return
    end
  end
end
