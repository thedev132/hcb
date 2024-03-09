# frozen_string_literal: true

module OrganizerPositionInviteService
  class Create
    def initialize(event:, sender: nil, user_email: nil, initial: false, is_signee: nil, role: nil)
      @event = event
      @sender = sender
      @user_email = normalize_email(user_email)
      @initial = initial
      @is_signee = is_signee
      @role = role

      args = {}
      args[:event] = @event
      args[:sender] = @sender
      args[:initial] = @initial
      args[:is_signee] = @is_signee
      args[:role] = @role if role

      @model = OrganizerPositionInvite.new(args)
    end

    def run
      ActiveRecord::Base.transaction do
        find_or_create_user

        @model.save
      end
    rescue ActiveRecord::RecordInvalid => e
      @model.errors.add(:base, message: e.message)
      false # signal that we didn't save the model properly
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
      # canonicalize emails as soon as possible -- otherwise, HCB gets
      # confused about who's invited and who's not when they log in.
      email&.downcase
    end

  end
end
