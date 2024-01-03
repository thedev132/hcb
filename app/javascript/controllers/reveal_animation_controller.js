import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.value = this.element.innerText
    this.step = 0

    this.interval = setInterval(() => {
      this.element.innerText = this.generateText()
      this.step++
    }, 100)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  generateText() {
    let result = this.value.slice(0, this.step)

    for (let i = 0; i < this.value.length - this.step; i++) {
      result += Math.floor(Math.random() * 10).toString()
    }

    if (this.step == this.value.length && this.interval) {
      clearInterval(this.interval)
    }

    return result
  }
}
