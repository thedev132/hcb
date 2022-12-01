# Flow

### Default

- User swipes card
- Bank determines if a TX is going through (ie. don't continue if balance is low)
- Sends an SMS to user asking them to reply with receipt
- User sends receipt in reply
- Bank uploads receipt to latest SMS

### Subscription

- User's card is charged a monthly subscription
- Bank detects that charge is a monthly subscription that they've already uploaded a receipt for & marks the transaction as 'subscription'– not required

### Admin

- A user is confused and messages the ops team saying they tried to upload a receipt that didn't go through.
- An admin pulls up their dashboard and checks the log of SMS messages

---

### MVP for the time being:

- Set your phone number
- Opt-into the feature-flag on '/my/settings'
- When charge comes in, send SMS with link

### Potential debt:

_All should be addressed before marking as generally available_

- What part of the codebase triggers this?
  - Currently it's a service that's called in the same place our receipt mailer is called

- This hardcodes the phone number twilio uses
  - Make sure to document this

- New fields in rails credentials
  - Should we update our development credentials?

- This document should be deleted

- What is tied to an outgoing SMS message?
  - HCB is an option, but this is triggered from the cpt
  - cpt is an option b/c it's triggered from the stripe cpt being created