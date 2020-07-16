# Preview all emails at http://localhost:3000/rails/mailers/check_mailer
class CheckMailerPreview < ActionMailer::Preview
  # Preview undeposited at http://localhost:3000/rails/mailers/check_mailer/undeposited
  def undeposited
    config = {
      check: Check.last
    }
    CheckMailer.with(config).send __method__
  end

  # Preview undeposited_organizers at http://localhost:3000/rails/mailers/check_mailer/undeposited_organizers
  def undeposited_organizers
    config = {
      check: Check.last
    }
    CheckMailer.with(config).send __method__
  end
end