import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['realCheckbox', 'docsPos', 'docsNeg']
  connect() {
    this.isChecked = this.realCheckboxTarget.checked

    this.updateIcon()
  }

  toggle() {
    this.isChecked = !this.isChecked
    this.realCheckboxTarget.checked = this.isChecked

    this.updateIcon()
  }

  updateIcon() {
    this.docsPosTarget.style.display = this.isChecked ? 'block' : 'none'
    this.docsNegTarget.style.display = !this.isChecked ? 'block' : 'none'
  }
}
