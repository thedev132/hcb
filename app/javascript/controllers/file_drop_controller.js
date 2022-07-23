import { Controller } from '@hotwired/stimulus'

let dropzone

export default class extends Controller {
  static targets = ['fileInput', 'dropzone', 'form', 'uploadMethod']
  static values = {
    title: String
  }

  initialize() {
    // Explanation: https://stackoverflow.com/a/21002544/10987085
    this.counter = 0

    this.submitting = false
  }

  dragover(e) {
    e.preventDefault()
  }

  drop(e) {
    e.preventDefault()

    this.counter = 0
    this.hideDropzone()

    this.fileInputTarget.files = e.dataTransfer.files
    if (!this.fileInputTarget.files.length) return

    if (this.hasUploadMethodTarget && !this.submitting) {
      // Append `_drag_and_drop` to the upload method
      this.uploadMethodTarget.value += '_drag_and_drop'
    }

    if (this.hasFormTarget) {
      this.formTarget.submit()
    } else {
      this.element.submit()
    }

    this.submitting = true
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
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.classList.add('dropzone')
      return
    }

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
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.classList.remove('dropzone')
      return
    }

    if (dropzone) {
      dropzone.remove()
      dropzone = undefined
      document.body.style.overflow = 'auto'
    }
  }
}
