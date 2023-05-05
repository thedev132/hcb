import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  select() {
    this.inputTarget.select()
  }

  focus() {
    this.inputTarget.focus()
  }
}
