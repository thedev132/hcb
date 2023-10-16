import { Controller } from '@hotwired/stimulus'
import ahoy from 'ahoy.js'

export default class extends Controller {
  static values = {
    eventName: String
  }

  track() {
    ahoy.track(this.eventNameValue)
  }
}
