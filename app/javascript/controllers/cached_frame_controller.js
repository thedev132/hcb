import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const cached = localStorage.getItem(`cached_frame:${this.element.id}`)

    if (cached) {
      this.element.innerHTML = cached
    }
  }

  cache(e) {
    localStorage.setItem(`cached_frame:${this.element.id}`, e.target.innerHTML)
  }
}
