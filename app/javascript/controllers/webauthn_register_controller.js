import { Controller } from '@hotwired/stimulus'
import { create } from '@github/webauthn-json'

export default class extends Controller {
  static values = {
    optionsUrl: String
  }
  static targets = [
    'error',
    'submitButton',
    'credentialInput',
    'platformRadio',
    'crossPlatformRadio',
    'nameInput',
    'nameLabel'
  ]

  // Toggles the `name` field based on the authenticator type
  toggleNameField() {
    if (this.platformRadioTarget.checked) {
      this.nameInputTarget.required = false
      this.nameInputTarget.placeholder = 'e.g. iPhone'
      this.nameLabelTarget.innerHTML =
        'Device name <span class="muted">(optional)</span>'
    } else {
      this.nameInputTarget.required = true
      this.nameInputTarget.placeholder = 'e.g. Yubikey'
      this.nameLabelTarget.innerText = 'Name'
    }
  }

  async connect() {
    // shout-out to this AMAZING article, without which I wouldn't have figured this out ~ @cjdenio
    // https://www.twilio.com/blog/detect-browser-support-webauthn
    const platformAuthAvailable =
      await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()

    if (!platformAuthAvailable) {
      this.crossPlatformRadioTarget.checked = true
      this.platformRadioTarget.disabled = true
    } else {
      this.platformRadioTarget.checked = true
      this.platformRadioTarget.disabled = false
    }

    this.toggleNameField()
  }

  async submit(e) {
    e.stopImmediatePropagation()
    e.preventDefault()

    try {
      this.submitButtonTarget.disabled = true
      this.errorTarget.classList.add('display-none')

      const params = new URLSearchParams({
        type: this.platformRadioTarget.checked ? 'platform' : 'cross-platform'
      })

      const options = await fetch(this.optionsUrlValue + `?${params}`).then(r =>
        r.json()
      )
      const credential = await create({ publicKey: options })

      this.credentialInputTarget.value = JSON.stringify(credential)
      this.element.submit()
    } catch (e) {
      if (e instanceof DOMException && e.name != 'AbortError') {
        this.errorTarget.classList.remove('display-none')
        console.error(e)
      }
    } finally {
      this.submitButtonTarget.disabled = false
    }
  }
}
