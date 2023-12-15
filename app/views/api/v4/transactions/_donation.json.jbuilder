# frozen_string_literal: true

json.recurring donation.recurring?
json.donor do
  json.name donation.name
  json.email donation.email
  json.recurring_donor_id donation.recurring_donation.hashid if donation.recurring?
end
json.donated_at donation.donated_at
