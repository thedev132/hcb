import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form']

  submit() {
    this.form.requestSubmit()
  }

  reset() {
    this.form.reset()
  }

  get form() {
    if (this.hasFormTarget) {
      return this.formTarget
    } else {
      return this.element
    }
  }
}
