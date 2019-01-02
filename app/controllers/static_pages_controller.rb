class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit

  def index
    if signed_in?
      @events = current_user.events
      @invites = current_user.organizer_position_invites.pending
    end
    if admin_signed_in?
      @transaction_volume = Transaction.total_volume
      @active = {
        card_requests: CardRequest.under_review.count,
        load_card_requests: LoadCardRequest.under_review.count,
        g_suite_applications: GSuiteApplication.under_review.count,
        g_suite_accounts: GSuiteAccount.under_review.count,
        transactions: Transaction.uncategorized.count,
        emburse_transactions: EmburseTransaction.under_review.count,
        organizer_position_deletion_requests: OrganizerPositionDeletionRequest.under_review.count
      }
    end
  end
end
