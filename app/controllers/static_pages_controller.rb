class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [ :apply, :submit ]

  def index
    if signed_in?
      @events = current_user.events
      @invites = current_user.organizer_position_invites.pending

      if @events.size == 1 && @invites.size == 0
        redirect_to current_user.events.first
      end
    end
    if admin_signed_in?
      @transaction_volume = Transaction.total_volume
      @active = {
        card_requests: CardRequest.under_review.size,
        load_card_requests: LoadCardRequest.under_review.size,
        g_suite_applications: GSuiteApplication.under_review.size,
        g_suite_accounts: GSuiteAccount.under_review.size,
        transactions: Transaction.uncategorized.size,
        emburse_transactions: EmburseTransaction.under_review.size,
        organizer_position_deletion_requests: OrganizerPositionDeletionRequest.under_review.size
      }
    end
  end

  def apply
  end

  def submit
    # TODO: submission logic
  end
end
