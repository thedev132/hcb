import { Controller } from '@hotwired/stimulus'
import { get } from '@github/webauthn-json'

export default class extends Controller {
  static targets = ['error', 'authButton', 'form', 'credentialInput']

  async auth() {
    try {
      this.authButtonTarget.disabled = true
      this.errorTarget.classList.add('display-none')

      const options = await fetch('/users/webauthn/auth_options').then(r =>
        r.json()
      )

      const credential = await get({
        publicKey: options
      })

      this.credentialInputTarget.value = JSON.stringify(credential)

      this.formTarget.submit()
    } catch (e) {
      if (e instanceof DOMException && e.name != 'AbortError') {
        this.errorTarget.classList.remove('display-none')
        console.error(e)
      }
    } finally {
      this.authButtonTarget.disabled = false
    }
  }
}
