class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :login_code, :exchange_login_code]
  skip_after_action :verify_authorized, except: [:edit, :update]
  before_action :hide_footer

  def impersonate
    authorize current_user

    impersonate_user(User.find(params[:user_id]))

    redirect_to(params[:return_to] || root_path)
  end

  # view to log in
  def auth
    @return_to = params[:return_to]
  end

  # post to request login code
  def login_code
    @return_to = params[:return_to]
    @email = params[:email].downcase

    resp = ::Partners::HackclubApi::RequestLoginCode.new(email: @email).run

    @user_id = resp[:id]
  end

  # post to exchange auth token for access token
  def exchange_login_code
    user = UserService::ExchangeLoginCodeForUser.new(user_id: params[:user_id], login_code: params[:login_code]).run

    sign_in(user)

    if user.full_name.blank? || user.phone_number.blank?
      redirect_to edit_user_path(user.slug)
    else
      redirect_to(params[:return_to] || root_path)
    end
  rescue Errors::InvalidLoginCode => e
    flash[:error] = e.message

    return render :login_code
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
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

    flash[:success] = 'Switched back to your Gravatar.'
    redirect_to edit_user_path(@user.slug)
  end

  private

  def user_params
    params.require(:user).permit(
      :full_name,
      :phone_number,
      :profile_picture,
      :pretend_is_not_admin,
      :sessions_reported
    )
  end
end
