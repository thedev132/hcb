# frozen_string_literal: true

module AuthService
  class Token
    # @param [LoginToken] token
    def initialize(token:, ip: nil)
      @token = token
      @ip = ip
      @already_used = nil
    end

    # @return [[User, TrueClass | FalseClass]]
    def run
      user
    rescue ActiveRecord::RecordNotFound
      raise UnauthenticatedError
    ensure
      @already_used = login_token.used?
      login_token.mark_used!(@ip) rescue nil
    end

    # The purpose of this method is to identify scenarios where a user should
    # not be allowed to login automatically via login token url.
    #
    # @return [Boolean] returns true if the user should be forced to manually login
    def force_manual_login?
      # Token must not have been used before
      if @already_used
        puts "Token #{login_token.token}: Token has already been used"
        return true
      end

      # User must have logged in before. This will allow us to validate they
      # own the email address
      if user_sessions.with_deleted.empty?
        puts "Token #{login_token.token}: User has not logged in before"
        return true
      end

      # The IP address must have been used before by a "trusted" session
      if @ip.present? && trusted_ips.exclude?(@ip)
        puts "Token #{login_token.token}: IP address #{@ip} has not been "\
          "previously used by a trusted session"
        return true
      end

      # After a user clicks "sign out of all sessions", force manual login
      if recently_signed_out_all?
        puts "Token #{login_token.token}: User has recently signed out of all sessions"
        return true
      end

      puts "Token #{login_token.token}: User is not forced to manually login"
      false

    rescue ActiveRecord::RecordNotFound
      raise UnauthenticatedError
    end

    def login_token
      @login_token ||= ::LoginToken.active.find_by!(token: @token)
    end

    private

    # @return [User]
    def user
      @user ||= login_token.user
    end

    def user_sessions
      @user_sessions ||= user.user_sessions
    end

    def trusted_ips
      # Get list of active session and peacefully deleted sessions
      trusted_sessions = user_sessions.all + user_sessions.only_deleted.peacefully_expired

      # Place active sessions at top and sort deleted by delete_at
      trusted_sessions = trusted_sessions.sort_by { |session|
        session.deleted_at.nil? ? Time.now : session.deleted_at
      }.reverse

      # Make session unique based on IP address (with respect to sort from above)
      trusted_sessions = trusted_sessions.select.with_index { |session, index|
        next false if session.ip.nil?

        # Filter out duplicates
        dup_index = trusted_sessions.index { |x| x.ip == session.ip }
        next false unless dup_index == index

        # Require that the session not be created more than 6 months ago
        session.created_at > 6.months.ago
      }

      trusted_sessions
        .pluck(:ip)
    end

    def recently_signed_out_all?
      # If the user has an active session, then they did not recently sign out all
      return false if user_sessions.any?

      # Just compare the last two deleted sessions make sure they were
      # deleted at about the same time
      deleted_at_a, deleted_at_b = user_sessions.only_deleted
                                                .order(deleted_at: :desc)
                                                .limit(2)
                                                .pluck(:deleted_at)

      return false if deleted_at_a.blank? || deleted_at_b.blank?

      (deleted_at_a - deleted_at_b) < 2.seconds
    end

  end
end
