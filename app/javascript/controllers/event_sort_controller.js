import { Controller } from '@hotwired/stimulus'
import csrf from '../common/csrf'

export default class extends Controller {
  static values = {
    organizerPositions: Array
  }

  async stop({ detail: { oldIndex, newIndex } }) {
    const copy = this.organizerPositionsValue

    const id = copy[oldIndex]

    copy.splice(oldIndex, 1)
    copy.splice(newIndex, 0, id)

    this.organizerPositionsValue = copy

    await fetch(`/organizer_positions/${id}/set_index`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf()
      },
      body: JSON.stringify({ index: newIndex })
    })
  }
}
