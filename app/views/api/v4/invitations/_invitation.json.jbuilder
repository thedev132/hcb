json.id invitation.public_id
json.created_at invitation.created_at
json.sender { json.partial! "api/v4/users/user", user: invitation.sender }
json.organization { json.partial! "api/v4/events/event", event: invitation.event }
