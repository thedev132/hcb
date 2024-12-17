_Last updated on May 3, 2021._

## Internal API for operations (clubs) integration

These APIs are not public, but have a reasonable expectation of stability because the Hack Club clubs team integrates with various HCB facilities through these JSON endpoints. They're oriented around three use cases:

1. Send money to a student to spend on a project
   - Student either specifies a HCB event, or we create one for them
   - We disburse funds to that event
2. Send money to a club or event
   - We find out their HCB event slug (probably referencing Slack / Airtable, which happens outside of HCB)
   - We disburse funds to that event

So to make this possible, the HCB API currently supports three actions:

1. Check if an event with given slug exists
2. Create an event with given organizer emails
3. Schedule a disbursement of grants to a given event

### Authentication

Because HCB currently uses auth through `hackclub/api` which doesn't support bot authentication and tokens, we auth with a hard-coded string key. Get this key from a HCB developer, and in JSON requests, include the key as a `token`.

### Creating events

#### `GET /api/v1/events/find`

Request should have parameters:

```
slug: <string>
```

Response will be of shape:

```
HTTP 200
{
    name: <string>,
    organizer_emails: Array<string>,
    total_balance: <number>,
}
```

or

```
HTTP 404
```

`total_balance` will be the sum of their account and card balances, in dollars.

#### `POST /api/v1/events`

Request should be of shape:

```
{
    name: <string>,
    slug: <string>, [optional]
    organizer_emails: Array<string>,
}
```

`slug` is optional. If no `slug` is provided, we'll take the name and attempt to sluggify it. Events created this way will be `unapproved`.

Response will be of shape:

```
HTTP 201
{
    name: <string>,
    slug: <string>,
    organizer_emails: Array<string>,
}
```

or an error of type 400 (invalid input). If a successful response (201), no fields will be missing.

### Requesting disbursements

Disbursements are executed using the `Disbursement` model / system within HCB.

#### `POST /api/v1/disbursements`

Disbursements take money out of one HCB event and into another HCB event, for example from the `hq` event into the `hackpenn` event. In this case, the `source_event_slug` is `hq` and `destination_event_slug` is `hackpenn`.

You can view all past and pending disbursements at `/disbursements`.

Request should be of shape:

```
{
    source_event_slug: <string>,
    destination_event_slug: <string>,
    amount: <number>,
    name: <string>,
}
```

Amount is in dollars in decimals, name is the name of the disbursement / grant. For example, a sensible `name` could be `GitHub Grant`. This name will be shown to HCB users.

Response will be of shape:

```
HTTP 201
{
    source_event_slug: <string>,
    destination_event_slug: <string>,
    amount: <number>,
    name: <string>,
}
```

or one of

```
HTTP 404 - no event with that slug was found
HTTP 400 - generic invalid input
```

If a `201` response, all fields will always be present.

## Events

```
settledTransactionCreated
pendingTransactionCreated
```
