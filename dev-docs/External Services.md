## External Services

- [DocuSign](#setting-up-docusign)
- [Plaid](#plaid)

## Setting up DocuSign

Well first of all, this experience sucks!! To start, you'll need a developer
DocuSign account. This account is not initially tied to your normal (production)
DocuSign account. After creating an app and getting approve, your app then gets
transferred from your developer account to your production account.

### Development DocuSign (requires in order to get to production)

- DocuSign requires that an app is built, tested, and then approved
  (to "go-live") before you even get a chance to use it in production.
- Start by creating a development account (or using an existing one)
  - We currently use signatures@hackclub.com for both our development and
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
  to production DocuSign. (we use signatures@hackclub.com — details in 1Password)
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
  - `admin`: HCB ("Zach Latta < signatures@hackclub.com>")
  - These roles are referenced by HCB when creating a signing URL
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

HCB uses Plaid to sync transactions from our bank Accounts (e.g. SVB)
into this app. Those transactions are saved as RawPlaidTransactions. Our main
account (FS Main on SVB) is authenticated with Plaid through Max's SVB account
(`max@hackclub.com`).
