# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def user_or_admin?
    user_or_admin
  end

  def index?
    user&.admin?
  end

  def toggle_hidden?
    user&.admin?
  end

  def new?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def show?
    is_public || user_or_admin
  end

  # NOTE(@lachlanjc): this is bad, I’m sorry.
  # This is the StripeCardsController#shipping method when rendered on the event
  # card overview page. This should be moved out of here.
  def shipping?
    user_or_admin
  end

  def by_airtable_id?
    user&.admin?
  end

  def edit?
    user_or_admin
  end

  def update?
    user_or_admin
  end

  def destroy?
    user&.admin? && record.demo_mode?
  end

  def team?
    is_public || user_or_admin
  end

  def emburse_card_overview?
    is_public || user_or_admin
  end

  def card_overview?
    is_public || user_or_admin
  end

  def documentation?
    is_public || user_or_admin
  end

  def demo_mode_request_meeting?
    user_or_admin
  end

  # (@eilla1) these pages are for the wip resources page and should be moved later
  def connect_gofundme?
    is_public || user_or_admin
  end

  def async_balance?
    is_public || user_or_admin
  end

  def new_transfer?
    user_or_admin
  end

  def receive_check?
    is_public || user_or_admin
  end

  def sell_merch?
    is_public || user_or_admin
  end

  def g_suite_overview?
    user_or_admin && !record.hardware_grant?
  end

  def g_suite_create?
    user_or_admin && is_not_demo_mode? && !record.hardware_grant?
  end

  def g_suite_verify?
    user_or_admin
  end

  def transfers?
    is_public || user_or_admin
  end

  def promotions?
    (is_public || user_or_admin) && !record.hardware_grant? && !record.outernet_guild?
  end

  def reimbursements?
    is_public || user_or_admin
  end

  def donation_overview?
    is_public || user_or_admin
  end

  def partner_donation_overview?
    is_public || user_or_admin
  end

  def remove_header_image?
    user_or_admin
  end

  def remove_background_image?
    user_or_admin
  end

  def remove_logo?
    user_or_admin
  end

  def enable_feature?
    user_or_admin
  end

  def disable_feature?
    user_or_admin
  end

  def account_number?
    is_public || user_or_admin
  end

  def user_or_admin
    user&.admin? || record.users.include?(user)
  end

  def is_not_demo_mode?
    !record.demo_mode?
  end

  def is_public
    record.is_public?
  end

end
