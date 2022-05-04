import { Controller } from '@hotwired/stimulus'

let dropzone

export default class extends Controller {
  static targets = ['fileInput']
  static values = {
    title: String
  }

  initialize() {
    // Explanation: https://stackoverflow.com/a/21002544/10987085
    this.counter = 0
  }

  dragover(e) {
    e.preventDefault()
  }

  drop(e) {
    e.preventDefault()

    this.counter = 0
    this.hideDropzone()

    this.fileInputTarget.files = e.dataTransfer.files

    this.element.submit()
  }

  dragenter() {
    if (this.counter == 0) {
      this.showDropzone()
    }
    this.counter++
  }

  dragleave() {
    this.counter--
    if (this.counter == 0) {
      this.hideDropzone()
    }
  }

  /* Utilities */

  showDropzone() {
    if (!dropzone) {
      dropzone = document.createElement('div')
      dropzone.classList.add('file-dropzone')

      const title = document.createElement('h1')
      title.innerText = this.titleValue
      dropzone.appendChild(title)

      document.body.appendChild(dropzone)
      document.body.style.overflow = 'hidden'

      // Explanation: https://stackoverflow.com/a/24195487/10987085
      window.getComputedStyle(dropzone).opacity

      dropzone.classList.add('visible')
    }
  }

  hideDropzone() {
    if (dropzone) {
      dropzone.remove()
      dropzone = undefined
      document.body.style.overflow = 'auto'
    }
  }
}
