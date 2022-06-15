# frozen_string_literal: true

module OrganizerPositionInviteService
  class Create
    def initialize(event:, sender: nil, user_email: nil)
      @event = event
      @sender = sender
      @user_email = normalize_email(user_email)
      @model = OrganizerPositionInvite.new(event: @event, sender: @sender, email: @user_email)
    end

    def run
      ActiveRecord::Base.transaction do
        find_or_create_user

        @model.save
      end
    end

    def run!
      ActiveRecord::Base.transaction do
        find_or_create_user

        @model.save!
      end
    end

    # This isn't ideal, but expose the model directly for dealing with errors or forms
    def model
      @model
    end

    private

    def find_or_create_user
      # Create the invited user now if it doesn't exist
      @model.user = User.find_or_create_by!(email: @user_email)
    end

    def normalize_email(email)
      # canonicalize emails as soon as possible -- otherwise, Bank gets
      # confused about who's invited and who's not when they log in.
      email&.downcase
    end

  end
end
