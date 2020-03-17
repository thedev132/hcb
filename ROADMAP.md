# Bank Roadmap

Three main things on Bank's plate:

- Follow through with Clubs team
- Cleaning up existing UX pain points with users
- Working on bigger foundational projects during this time (see "Big-ticket items" below)

@tmb - iterative move to Stripe Issuing
@thesephist - UX cleanup & calls with existing users

\* We should sync every 2-3 days.

## Auth

Proposal: Mostly-stateless authentication service that just provides pairing of session tokens to Email / SMSes.

Requirements:
- Auth methods
    - email auth
    - SMS auth
- Multi-session support
- Longer sessions ("remember this computer")
- Allow other services to talk to it

Best effort:
- Ability to see + exit out of other logged-in sessions (This allows longer sessions to be safe)

## Clubs tools

- Grant-only account (flag that disables invoicing)
    - Make a page for explaining different plans and how to change it, link from events settings
- Quest for when you first make an account.
    - Should be for a user's first event.
- Virtual cards
    - Make sure emails that go out for card creations know about virtual cards
    - Make sure physical card requests validate that there's all the required address fields in the req.

## Stripe Issuing

- Receipt collection
- One True Balance (single balance, managed behind the scenes)

## Big-ticket items

Higher priority items (concrete current need or pain point)

- Onboarding flow -- "Quests"
    - https://github.com/hackclub/bank/issues/539
- Robust notification system
    - Ability to aggregate notifications and receive them in bulk for a day/week
- Reimbursements

Lower priority items

- International support
    - Mailing cards internationally
    - Support international addresses for sending invoices
- Faster bank sync (probably with a different underlying bank?)
- Demo ~accounts~ video-- scratch that in favor of good video walk through
- New marketing site / landing page
- Google Groups support _a la_ G Suite
- New name

## Iterative enhancements

- Hardware rental
- Subdomains (under hackclub.com)
- URL shortener (under hack.af)
- Swag page
