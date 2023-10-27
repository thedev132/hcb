# frozen_string_literal: true

user = User.first

if user.nil?
  puts "Woah there, there aren't any users! Please sign in first."
else
  puts "Continuing with #{user.email}..."

  user.make_admin! if !user.admin?

  event = Event.create_with(
    name: "Test Org",
    slug: "test",
    can_front_balance: true,
    point_of_contact: user,
    sponsorship_fee: 0.07,
    organization_identifier: "bank_#{SecureRandom.hex}",
  ).find_or_create_by!(slug: "test")

  OrganizerPositionInvite.create!(
    event:,
    user:,
    sender: user,
  )

  puts "Done!"
end
