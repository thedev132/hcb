import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { usdzHref: String, href: String }

  connect() {
    if (this.element.relList.supports('ar')) {
      this.element.href = this.usdzHrefValue
      this.element.rel = 'ar'
    } else if (this.hasHrefValue) {
      this.element.href = this.hrefValue
    }
  }
}
