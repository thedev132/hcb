import { Controller } from '@hotwired/stimulus'
import { debounce } from 'lodash/function'
import csrf from '../common/csrf'

export default class extends Controller {
  static values = { url: String }
  static targets = ['hint']

  initialize() {
    this.validate = debounce(this._validate, 500)
  }

  async _validate(e) {
    const { valid, hint } = await fetch(this.urlValue, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrf() },
      body: JSON.stringify({
        value: e.target.value
      })
    }).then(r => r.json())

    if (valid) {
      this.element.classList.remove('field_with_errors')
    } else {
      this.element.classList.add('field_with_errors')
    }

    if (this.hasHintTarget) {
      this.hintTarget.innerText = hint || ''
      if (valid) {
        this.hintTarget.classList.remove('primary')
        this.hintTarget.classList.add('muted')
      } else {
        this.hintTarget.classList.remove('muted')
        this.hintTarget.classList.add('primary')
      }
    }
  }
}
