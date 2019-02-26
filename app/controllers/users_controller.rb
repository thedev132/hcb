class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :login_code, :exchange_login_code]
  skip_after_action :verify_authorized, except: [:edit, :update]

  # view to log in
  def auth
  end

  # post to request login code
  def login_code
    @email = params[:email].downcase

    resp = ApiService.request_login_code(@email)

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
    u.admin_at = u.api_record[:admin_at]

    u.save

    sign_in u
    if u.full_name.blank? || u.phone_number.blank?
      redirect_to edit_user_path(u)
    else
      redirect_back_or root_path
    end
  end

  def logout
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
      flash[:success] = 'Updated your profile!'
      redirect_to params[:redirect_to] || root_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :phone_number)
  end
end
