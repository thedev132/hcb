# frozen_string_literal: true

user = User.first

if user.nil?
  puts "Woah there, there aren't any users! Please sign in first."
else
  puts "Continuing with #{user.email}..."

  user.update!(admin_at: Time.now) if !user.admin?

  partner = Partner.create_with(
    id: 1,
    name: "Bank",
    external: false,
  ).find_or_create_by!(slug: "bank")

  event = Event.create_with(
    name: "Test Org",
    slug: "test",
    can_front_balance: true,
    point_of_contact: user,
    partner:,
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
