# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    user == record
  end

  def impersonate?
    user.admin?
  end

  def edit?
    user.admin? || record == user
  end

  def edit_address?
    user.admin? || record == user
  end

  def edit_featurepreviews?
    user.admin? || record == user
  end

  def edit_security?
    user.admin? || record == user
  end

  def edit_admin?
    user.admin? || (record == user && user.admin_override_pretend?)
  end

  def update?
    user.admin? || record == user
  end

  def delete_profile_picture?
    user.admin? || record == user
  end

  def toggle_sms_auth?
    user.admin? || record == user
  end

  def start_sms_auth_verification?
    user.admin? || record == user
  end

  def complete_sms_auth_verification?
    user.admin? || record == user
  end

  def receipt_report?
    user.admin? || record == user
  end

  def enable_feature?
    user.admin? || record == user
  end

  def disable_feature?
    user.admin? || record == user
  end

  def wrapped?
    user.admin? || record == user
  end

end
