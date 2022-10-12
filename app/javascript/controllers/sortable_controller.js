import { Controller } from '@hotwired/stimulus'
import { Sortable, Plugins } from '@shopify/draggable'

export default class extends Controller {
  static values = {
    appendTo: String
  }

  connect() {
    this.sortable = new Sortable(this.element, {
      draggable: '.draggable',
      mirror: {
        constrainDimensions: true,
        appendTo: this.appendToValue
      },
      distance: 10,
      plugins: [Plugins.SortAnimation]
    })

    this.sortable.on('sortable:sorted', e => {
      this.dispatch('sorted', { detail: e })
    })

    this.sortable.on('sortable:stop', e => {
      this.dispatch('stop', { detail: e })
    })
  }

  disconnect() {
    this.sortable.destroy()
  }
}
