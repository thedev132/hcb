import { Controller } from '@hotwired/stimulus'
import { get } from '@github/webauthn-json'
import UAParser from 'ua-parser-js'
import FingerprintJS from '@fingerprintjs/fingerprintjs'
import submitForm from '../common/submitForm'

export default class extends Controller {
  static targets = [
    'authForm',
    'loginEmailInput',
    'error',
    'loginCode',
    'continueButton'
  ]

  static values = {
    returnTo: String
  }

  loginEmailInputTargetConnected() {
    this.loginEmailInputTarget.value = localStorage.getItem('login_email')
  }

  async submit(event) {
    event.preventDefault()
    event.stopImmediatePropagation()

    this.disableForm()

    const loginEmail = event.target.email.value

    try {
      const options = await this.fetchWebAuthnOptions(loginEmail)

      this.loginCodeTarget.classList.remove('display-none')
      this.continueButtonTarget.value = 'Waiting for security key... '

      const credential = await get({
        publicKey: options
      })

      this.storeLoginEmail(loginEmail)

      submitForm('/users/webauthn', {
        credential: JSON.stringify(credential),
        email: loginEmail,
        return_to: this.returnToValue,
        ...(await this.fingerprint())
      })
    } catch (e) {
      if (e.message == "User doesn't have WebAuthn enabled") {
        // Submit the form normally
        this.storeLoginEmail(loginEmail)

        event.target.submit()
      } else {
        // Show an error
        this.enableForm()
        this.continueButtonTarget.value = 'Continue'

        this.errorTarget.classList.remove('display-none')
      }
    }
  }

  loginCode(e) {
    e.preventDefault()

    this.storeLoginEmail(this.loginEmailInputTarget.value)

    this.authFormTarget.submit()
  }

  disableForm() {
    this.authFormTarget
      .querySelectorAll('input[type=submit], button')
      .forEach(x => (x.disabled = true))
  }

  enableForm() {
    this.authFormTarget
      .querySelectorAll('input[type=submit], button')
      .forEach(x => (x.disabled = false))
  }

  storeLoginEmail(email) {
    localStorage.setItem('login_email', email)
  }

  async fetchWebAuthnOptions(email) {
    const searchParams = new URLSearchParams()
    searchParams.set('email', email)

    const options = await fetch(
      `/users/webauthn/auth_options?${searchParams}`
    ).then(r => {
      if (!r.ok) throw new Error("User doesn't have WebAuthn enabled")

      return r.json()
    })

    return options
  }

  async fingerprint() {
    const result = new UAParser().getResult()
    const fingerprint = await FingerprintJS.load().then(fp => fp.get())

    return {
      fingerprint: fingerprint.visitorId,
      device_info: result.browser.name + ' ' + result.browser.version,
      os_info: result.os.name + ' ' + result.os.version,
      timezone: fingerprint.components.timezone.value
    }
  }
}
