module StaticPageService
  class Index
    def initialize(current_user:)
      @current_user = current_user
    end

    def redirect_to_first_event?
      !admin? && events.count == 1 && invites.count == 0
    end

    def events
      @current_user.events.includes(organizer_positions: :user)
    end

    def invites
      @current_user.organizer_position_invites.pending
    end
    
    # Counts

    def checks_count
      # While check sending isn't working, we don't want to show tasks in the
      # queue that Ops Team can't fulfill

      # Check.pending.count + Check.unfinished_void.count
      return 0
    end

    def ach_transfers_count
      AchTransfer.pending.count
    end

    def fee_reimbursements_count
      FeeReimbursement.unprocessed.count
    end

    def g_suites_needs_ops_review_count
      GSuite.needs_ops_review.count
    end

    def organizer_position_deletion_requests_count
      OrganizerPositionDeletionRequest.under_review.count
    end

    def transactions_count
      Transaction.needs_action.count
    end

    def pending_fees_count
      Event.pending_fees.count
    end

    def disbursements_count
      Disbursement.pending.count
    end

    private

    def admin?
      @current_user.admin?
    end
  end
end
