import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['preview']

  set(e) {
    this.previewTarget.style.backgroundImage = `url(${URL.createObjectURL(
      e.target.files[0]
    )})`
    this.previewTarget.classList.add('previewing')
    this.previewTarget.innerHTML = ''
  }
}
