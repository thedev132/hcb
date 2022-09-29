import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    eventName: String
  }

  event() {
    window.FS?.event(this.eventNameValue)
  }
}
