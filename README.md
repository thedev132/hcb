# Bank

Bank is a tool for hackers to hack on the real world, like GitHub, but for building with atoms and people, not bits and cycles.

![Hack Club Bank](hack_club_bank_laser.gif)

![Zeitwerk Check](https://github.com/hackclub/bank/workflows/Zeitwerk%20Check/badge.svg?branch=main)

## Getting Started

1. Install Docker.
2. Clone this repo.
3. Get a copy of the encrypted credentials key from a team member (`config/master.key`)
4. Copy `.env.example` to `.env` (`cp .env.example .env`) & edit `APP_PORT=3000` or whatever floats your boat in the port
5. ```sh
    docker-compose build
    docker-compose run web bundle exec rails db:create db:migrate
    docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000

    # Warning: `docker-compose up` will also spin up a background job worker to
    # work on jobs in your database. If you've restored a production database
    # dump, your local version may start sending emails/running jobs that were
    # queued in production. You can see your database's jobs at
    # http://localhost:3000/sidekiq
   ```

6. Open [localhost:3000](http://localhost:3000)

Alternatively, you can run `docker-compose run --service-ports web /bin/bash` to open a shell into the container with the right ports bound, and then manually start the Rails app, or just run `docker-compose run web bundle exec rails s -b 0.0.0.0` to start the rails server directly from Docker.

## Heroku tasks

We currently have the following buildpacks:

```
❯ heroku buildpacks
=== bank-hackclub Buildpack URLs
1. https://github.com/heroku/heroku-buildpack-apt
2. https://github.com/evantahler/heroku-buildpack-notify-slack-deploy.git
3. heroku/nodejs
4. heroku/ruby
```

The apt buildpack works in conjunction with the local Aptfile in order to install poppler-utils. Poppler-utils helps generate preview thumbnails of documents.

## Admin tasks

### Import database dump from Heroku

```
$ heroku git:remote -a bank-hackclub # if your repo isn't attached to the heroku app
$ heroku pg:backups:capture
$ heroku pg:backups:download # will save as latest.dump, double check to make sure that file is created
$ docker-compose run --service-ports web /bin/bash # enter the docker container, which includes pg_restore pre-installed
$ pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump
```

### Running migrations

Currently, migrations are decoupled from deployments. After deploying a patch with a new migration, run:

```
$ heroku run /bin/bash -a bank-hackclub
$ rails db:migrate:status
$ rails db:migrate
```

### Running tests

```
$ bundle exec rspec
```

### Log into the Rails console in production

```
heroku console -a bank-hackclub
```

We can also replace `bank-hackclub` with any other app name (like a review app) to get the console for that app instead.

### Restart periodic / repeating jobs

For example, for the `SyncTransactionsJob`:

```
SyncTransactionsJob.perform_now(repeat: true)
```

## Internal API for operations (clubs) integration

These APIs are not public, but have a reasonable expectation of stability because the Hack Club clubs team integrates with various Bank facilities through these JSON endpoints. They're oriented around three use cases:

1. Send money to a student to spend on a project
   - Student either specifies a Bank event, or we create one for them
   - We disburse funds to that event
2. Send money to a club or event
   - We find out their bank event slug (probably referencing Slack / Airtable, which happens outside of Bank)
   - We disburse funds to that event

So to make this possible, the Bank API currently supports three actions:

1. Check if an event with given slug exists
2. Create an event with given organizer emails
3. Schedule a disbursement of grants to a given event

### Authentication

Because Bank currently uses auth through `hackclub/api` which doesn't support bot authentication and tokens, we auth with a hard-coded string key. Get this key from a Bank developer, and in JSON requests, include the key as a `token`.

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

`slug` is optional. If no `slug` is provided, we'll take the name and attempt to sluggify it. Events created this way will be `spend_only`.

Response will be of shape:

```
HTTP 201
{
    name: <string>,
    is_spend_only: <boolean>,
    slug: <string>,
    organizer_emails: Array<string>,
}
```

or an error of type 400 (invalid input). If a successful response (201), no fields will be missing.

### Requesting disbursements

Disbursements are executed using the `Disbursement` model / system within Hack Club Bank.

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

Amount is in dollars in decimals, name is the name of the disbursement / grant. For example, a sensible `name` could be `GitHub Grant`. This name will be shown to Bank users.

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
