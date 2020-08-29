class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :login_code, :exchange_login_code]
  skip_after_action :verify_authorized, except: [:edit, :update]
  before_action :hide_footer

  def impersonate
    authorize current_user

    impersonate_user(User.find(params[:user_id]))

    redirect_to root_path, status: 302
  end

  # view to log in
  def auth
  end

  # post to request login code
  def login_code
    @email = params[:email].downcase

    resp = ::Partners::HackclubApi::RequestLoginCode.new(email: @email).run

    @user_id = resp[:id]
  end

  # post to exchange auth token for access token
  def exchange_login_code
    @user_id = params[:user_id]
    @email = params[:email]
    login_code = params[:login_code].to_s.gsub('-', '').gsub(/\s+/, '')

    resp = ::Partners::HackclubApi::ExchangeLoginCode.new(user_id: @user_id, login_code: login_code).run

    if resp[:errors].present?
      flash[:error] = 'Invalid login code'
      return render :login_code
    end

    access_token = resp[:auth_token]

    resp2 = ::Partners::HackclubApi::GetUser.new(user_id: @user_id, access_token: access_token).run

    u = User.find_or_initialize_by(email: resp2[:email])
    u.api_access_token = access_token 
    u.email = resp2[:email]
    u.admin_at = resp2[:admin_at] # TODO: remove admin_at as necessary from a 3rd party auth service

    u.save

    sign_in u
    if u.full_name.blank? || u.phone_number.blank?
      redirect_to edit_user_path(u.slug)
    else
      redirect_to root_path
    end
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def edit
    @user = User.friendly.find(params[:id])
    @onboarding = @user.full_name.blank?
    authorize @user
  end

  def update
    @user = User.friendly.find(params[:id])
    authorize @user

    if @user.update(user_params)
      flash[:success] = 'Updated your profile!'
      redirect_to root_path
    else
      render :edit
    end
  end

  def delete_profile_picture
    @user = User.friendly.find(params[:user_id])
    authorize @user

    @user.profile_picture.purge_later

    flash[:success] = "Switched back to Gravatar!"
    redirect_to edit_user_path(@user.slug)
  end

  private

  def user_params
    params.require(:user).permit(
      :full_name,
      :phone_number,
      :profile_picture,
      :pretend_is_not_admin,
    )
  end
end
