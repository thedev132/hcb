import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['radioButton', 'submitButton']

  initialize() {
    this.run()
  }

  run() {
    const enabled = this.radioButtonTargets.some(input => input.checked)

    this.submitButtonTarget.disabled = !enabled
  }
}
