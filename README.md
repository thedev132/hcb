# Bank

Bank is a tool for hackers to hack on the real world, like GitHub, but for building with atoms and people, not bits and cycles.

![Hack Club Bank](hack_club_bank_laser.gif)

## Getting Started with GitHub Codespaces

We're currently test running the Hack Club Bank development environment in [GitHub Codespaces](https://docs.github.com/en/codespaces). GitHub Codespaces allows for installation of packages without modifying your main system, allows for multiple instances, creates an overall streamlined and repeatable environment, and enables anyone with browser or VSCode access to contribute.

Assuming a successful testing phase, this will be the preferred method of running a development version of Bank.

Instructions on how to setup can be found [here](/codespace-steps.md). Premade `codespace-config.sh` and `codespace-start.sh` scripts exist for configuring the environment and starting instances.

## Getting Started Locally

Install [dotenv/cli](https://github.com/dotenv-org/cli)

```bash
npm install @dotenv/cli -g
```

And load the latest .env file to your local machine.

```bash
dotenv-cli pull
```

Install [rbenv](https://github.com/rbenv/rbenv)

```bash
brew install rbenv
```

Install [bundler](https://bundler.io/)

```bash
gem install bundler -v 1.17.3
```

Run bundler

```bash
bundle install
```

Install yarn dependencies

```bash
yarn install
```

Create and migrate database

```bash
bundle exec rake db:drop db:create db:migrate
```

Populate the database

```bash
heroku git:remote -a bank-hackclub # if your repo isn't attached to the heroku app
heroku pg:backups:capture
heroku pg:backups:download # will save as latest.dump, double check to make sure that file is created
pg_restore --verbose --clean --no-acl --no-owner -d bank_development latest.dump
```

Run the application

```bash
bin/rails s
```

## Running Selenium Tests

This assumes the following:
- Bank is running within Docker
- Your host machine has Google Chrome installed
- Your host machine has chromedriver installed. It can be installed with `brew install chromedriver`

With the assumptions above, run the following on your host machine's terminal:
```
# Start chromedriver
chromedriver --whitelisted-ips --allowed-origins="*"
# the `--whitelisted-ips` flag allows all ip addresses
# the `--allowed-origins="*"` flag allows all origins
```

Refer to this [guide](https://avdi.codes/run-rails-6-system-tests-in-docker-using-a-host-browser/) for more information.


## Additional Installs

Install wkhtmltopdf

```bash
brew install wkhtmltopdf
```

Browse to [localhost:3000](http://localhost:3000)

## Alternative with Docker

Copy .env file

```bash
cp .env.docker.example .env.docker
```

Run Docker

```bash
env $(cat .env.docker) docker-compose build
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails db:create db:migrate
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000
```

(Optional) Run Solargraph in Docker

[Solargraph](https://solargraph.org/demo) is a tool that provides IntelliSense, code completion, and inline documentation for Ruby. You may also need to install the [Solargraph extension](https://github.com/castwide/solargraph#using-solargraph) for your editor.

```bash
env $(cat .env.docker) docker-compose -f docker-compose.yml -f docker-compose.solargraph.yml build
env $(cat .env.docker) docker-compose -f docker-compose.yml -f docker-compose.solargraph.yml up -d solargraph
```

## Heroku tasks

Please check app.json for the buildpacks required to run Bank on Heroku.

The `heroku/metrics` buildpacks allow us to record in depth Ruby specific
metrics about the application.
See [PR #2236](https://github.com/hackclub/bank/pull/2236)
for more information.

The apt buildpack works in conjunction with the local Aptfile in order to
install poppler-utils. Poppler-utils helps generate preview thumbnails of
documents.

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

Migrations are [automatically run on deployment to Heroku](https://github.com/hackclub/bank/commit/d8eefe44dc9b2503ae1c42805681ad338dc89de1).

If for some reason you need to manually manage (or rollback) migrations, you can do so by running:

```
$ heroku run /bin/bash -a bank-hackclub
$ rails db:migrate:status
$ rails db:migrate # if you need to run migrations manually
$ rails db:rollback # if you need to rollback in production
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

## Events

```
settledTransactionCreated
pendingTransactionCreated
```

## Setting up DocuSign

Well first of all, this experience sucks!! To start, you'll need a developer
DocuSign account. This account is not initially tied to your normal (production)
DocuSign account. After creating an app and getting approve, your app then gets
transferred from your developer account to your production account.

### Development DocuSign (requires in order to get to production)

- DocuSign requires that an app is built, tested, and then approved
  (to "go-live") before you even get a chance to use it in production.
- Start by creating a development account (or using an existing one)
    - We currently use signature@hackclub.com for both our development and
      production accounts. (details in 1Password)
    - https://admindemo.docusign.com/
- Create an app and save the keys in Rails credentials
    - https://admindemo.docusign.com/apps-and-keys
    - Don't forget to restart your server after editing the credentials
- Create a template (this will be used for testing)
    - See the "DocuSign Template" section below for more instructions.
    - Each `Partner` model instance has a `docusign_template_id` field. Copy and
      paste the template ID from DocuSign into that field for one of the
      Partners. You'll be using this template for testing.
- Since we are using the OAuth code grant flow, we'll need to initially give our
  app permission to access our account. (giving consent)
    - Make sure you're logged into your development DocuSign account.
    - Visit the following
      url: https://account-d.docusign.com/oauth/auth?response_type=code&scope=signature%20impersonation&client_id=CLIENT_ID&redirect_uri=REDIRECT_URI
        - Replace `CLIENT_ID` with the app's integration key
        - The `REDIRECT_URI` must be registered within the app's settings on
          DocuSign
            - https://admindemo.docusign.com/apps-and-keys
        - More
          info: https://www.docusign.com/blog/developers/oauth-jwt-granting-consent
    - If this is not done correctly, you will receive a 400 DocuSign API
      error (`{"error":"consent_required"}`)
- Now you should be all set to use development mode DocuSign!
- Next: move onto production

### Production DocuSign

- You MUST already have development DocuSign working. It will require you to
  make a bunch of successful requests to DocuSign before you're able to apply
  to "go-live" (production).
- Apply to "go-live" (takes around 48 hours)
- Once approved, the app you created in development DocuSign will be transferred
  to production DocuSign. (we use signature@hackclub.com — details in 1Password)
- Login to **production** DocuSign
- Grab the new keys from the app's settings and save them in Rails credentials
    - Your app's integration key should stay the same as the once you used with
      development DocuSign.
- You NEED to go through the OAuth consent flow again.
  (giving consent)
    - Follow the "OAuth code grant flow" instruction for development (above)
    - However, use the following URL
      instead: https://account.docusign.com/oauth/auth?response_type=code&scope=signature%20impersonation&client_id=CLIENT_ID&redirect_uri=REDIRECT_URI
        - (the domain is now `account.docusign.com` instead
          of `account-d.docusign.com`)
    - More
      info: https://www.docusign.com/blog/developers/oauth-jwt-granting-consent
    - If this is not done correctly, you will receive a 400 DocuSign API
      error (`{"error":"consent_required"}`)
- Create a template (see instruction in DocuSign Template section below)
- Set the template ID in a `Partner` model instance's `docusign_template_id`
  field
- Now your should be all set to use production DocuSign!

### Setting up a DocuSign Template

- The template requires two roles:
    - `signer`: the person/"team" apply for Fiscal Sponsorship
    - `admin`: Hack Club Bank ("Zach Latta <signature@hackclub.com>")
    - These roles are referenced by Bank when creating a signing URL
- You should set a signing order (`signer`, then `admin`)
- Once you have a template id, you can add that to a `Partner` model instance's
  `docusign_template_id` field.
    - Each Partner can have a different template id.

### DocuSign Debug Tips

- If you need to debug, try debugging with production DocuSign locally on your
  machine. For some reason, the debug output from the DocuSign Ruby Client is
  different when running on production Rails (even when `debugging` is set to
  true on the DocuSign API instance's configurations)

## Plaid

Hack Club Bank uses Plaid to sync transactions from our Bank Accounts (e.g. SVB)
into this app. Those transactions are saved as RawPlaidTransactions. Our main
account (FS Main on SVB) is authenticated with Plaid through Max's SVB account
(`max@hackclub.com`).