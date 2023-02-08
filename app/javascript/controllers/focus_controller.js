import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['element']
  static values = {
    delay: {
      type: Number,
      default: 0
    }
  }

  focus() {
    setTimeout(() => {
      this.elementTarget.focus()
    }, this.delayValue)
  }
}
