import { Controller } from '@hotwired/stimulus'

let dropzone

function postNavigate (path, data) {
  const form = document.createElement('form')
  form.method = 'POST'
  form.action = path

  for (const key in data) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = key
    input.value = data[key]
    form.appendChild(input)
  }

  document.body.appendChild(form)
  form.submit()
}

function extractId (dataTransfer) {
  let receiptId

  try {
    const html = dataTransfer.getData('text/html')

    const parser = new DOMParser()
    const doc = parser.parseFromString(html, 'text/html')
    const imgTag = doc.querySelector('img')

    receiptId = imgTag.getAttribute('data-receipt-id')
  } catch (err) {
    console.error(err)
  }
  
  if (!receiptId) {
    try {
      const uri = dataTransfer.getData('text/uri-list')
      const { pathname } = new URL(uri)

      const linkElement = document.querySelector(`a[href~="${pathname}"]:has(img)`)
      const imageElement = linkElement.querySelector('img')

      receiptId = imageElement.getAttribute('data-receipt-id')
    } catch (err) {
      console.error(err)
    }
  }

  return receiptId
}

export default class extends Controller {
  static targets = ['fileInput', 'dropzone', 'form', 'uploadMethod']
  static values = {
    title: String,
    linking: String,
    receiptable: String,
    modal: String
  }

  initialize() {
    // Explanation: https://stackoverflow.com/a/21002544/10987085
    this.counter = 0

    this.submitting = false
  }

  dragover(e) {
    e.preventDefault()
  }

  async drop(e) {
    e.preventDefault()

    this.counter = 0
    this.hideDropzone()

    if (this.linkingValue == "true") {

      const receiptId = extractId(e.dataTransfer)

      const [receiptableType, receiptableId] = this.receiptableValue.split(':')
      const linkPath = this.modalValue;

      if (receiptId && receiptableType && receiptableId) {
        return postNavigate(linkPath, {
          receipt_id: receiptId,
          receiptable_type: receiptableType,
          receiptable_id: receiptableId,
          show_link: true,
          authenticity_token: document.querySelector('form[data-controller="receipt-select"] > input[name="authenticity_token"]').value // this is messy, there's probably a better way to do this
        });
      }

    }

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
