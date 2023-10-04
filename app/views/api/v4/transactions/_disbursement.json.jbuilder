json.from do
  json.partial! "api/v4/events/event", event: disbursement.source_event
end

json.to do
  json.partial! "api/v4/events/event", event: disbursement.destination_event
end

json.memo disbursement.name

json.sender do
  if disbursement.requested_by.present?
    json.partial! "api/v4/users/user", user: disbursement.requested_by
  else
    json.nil!
  end
end
