# frozen_string_literal: true

class CheckMailerPreview < ActionMailer::Preview
  def initialize( params = {} )
    super( params )

    @check = Check.voided.last
  end

  def undeposited
    CheckMailer.with(check: @check).undeposited
  end

  def undeposited_organizers
    CheckMailer.with(check: @check).undeposited_organizers
  end

end
